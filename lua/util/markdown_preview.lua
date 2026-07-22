local commands = require("util.external_commands")

local M = {}

local function notify(message, level, options)
  (options and options.notify or vim.notify)(message, level)
end

local function fail(message, options)
  notify("Markdown Preview patch failed: " .. message, vim.log.levels.ERROR, options)
  return false
end

local function paths(options)
  local plugin_dir = options and options.plugin_dir or vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
  local config_dir = options and options.config_dir or vim.fn.stdpath("config")
  return {
    plugin_dir = plugin_dir,
    static_dir = plugin_dir .. "/app/_static",
    out_html = plugin_dir .. "/app/out/index.html",
    toc_dir = config_dir .. "/assets/mkdp-toc",
    mkdp_dir = config_dir .. "/assets/mkdp",
  }
end

local function path_exists(path)
  local ok, stat = pcall((vim.uv or vim.loop).fs_stat, path)
  return ok and stat ~= nil
end

local function require_file(path, label, options)
  if vim.fn.filereadable(path) ~= 1 then
    return fail(label .. " is missing: " .. path, options)
  end
  return true
end

local function read_file(path, mode, label, options)
  if not require_file(path, label, options) then
    return nil
  end
  local ok, lines_or_error = pcall(vim.fn.readfile, path, mode)
  if not ok then
    fail("cannot read " .. label .. ": " .. path .. " (" .. tostring(lines_or_error) .. ")", options)
    return nil
  end
  return lines_or_error
end

local function write_file(path, lines, mode, options)
  local wrote, write_result
  if mode then
    wrote, write_result = pcall(vim.fn.writefile, lines, path, mode)
  else
    wrote, write_result = pcall(vim.fn.writefile, lines, path)
  end
  if not wrote or write_result ~= 0 then
    return fail("cannot write target: " .. path, options)
  end
  return true
end

local function run_system(command, options)
  local system = options and options.system or vim.fn.system
  local ok, _, exit_code = pcall(system, command)
  if not ok then
    return nil, tostring(_)
  end
  if exit_code == nil then
    exit_code = vim.v.shell_error
  end
  return exit_code == 0, exit_code
end

local function protect_index_html(plugin_dir, options)
  if not path_exists(plugin_dir .. "/.git") then
    return true
  end
  if not commands.executable("git") then
    return fail("git is unavailable; cannot protect patched index.html", options)
  end

  local command = { "git", "-C", plugin_dir, "update-index", "--skip-worktree", "app/out/index.html" }
  local ok, detail = run_system(command, options)
  if not ok then
    local suffix = type(detail) == "number" and " (exit " .. detail .. ")" or " (" .. detail .. ")"
    return fail("cannot protect patched index.html before mutation" .. suffix, options)
  end
  return true
end

local function copy_if_changed(source, target, options)
  local source_lines = read_file(source, "b", "source", options)
  if not source_lines then
    return false
  end

  if vim.fn.filereadable(target) == 1 then
    local target_lines = read_file(target, "b", "target", options)
    if not target_lines then
      return false
    end
    if vim.deep_equal(source_lines, target_lines) then
      return true
    end
  end

  if not write_file(target, source_lines, "b", options) then
    return false
  end
  local verified = read_file(target, "b", "target", options)
  if not verified or not vim.deep_equal(source_lines, verified) then
    return fail("could not verify target: " .. target, options)
  end
  return true
end

local function write_html(path, html, verify, options)
  if not write_file(path, vim.split(html, "\n", { plain = true }), nil, options) then
    return false
  end
  local verified_lines = read_file(path, nil, "target", options)
  if not verified_lines then
    return false
  end
  if not verify(table.concat(verified_lines, "\n")) then
    return fail("could not verify injected target: " .. path, options)
  end
  return true
end

local function inject_html(path, marker, pattern, replacement, options)
  local lines = read_file(path, nil, "target", options)
  if not lines then
    return false
  end
  if #lines == 0 then
    return fail("target is empty: " .. path, options)
  end
  local html = table.concat(lines, "\n")
  if html:find(marker, 1, true) then
    return true
  end

  local patched, count = html:gsub(pattern, replacement, 1)
  if count ~= 1 then
    return fail("cannot find injection point in: " .. path, options)
  end
  return write_html(path, patched, function(verified)
    return verified:find(marker, 1, true) ~= nil
  end, options)
end

local function patch_toc_html(path, options)
  local css = '<link rel="stylesheet" href="/_static/toc-sidebar.css"/>'
  local script = '<script src="/_static/toc-sidebar.js" defer></script>'
  local lines = read_file(path, nil, "target", options)
  if not lines then
    return false
  end
  if #lines == 0 then
    return fail("target is empty: " .. path, options)
  end
  local html = table.concat(lines, "\n")
  local has_css = html:find(css, 1, true) ~= nil
  local has_script = html:find(script, 1, true) ~= nil
  if has_css and has_script then
    return true
  end

  local patched
  if not has_css and has_script then
    local position = assert(html:find(script, 1, true))
    patched = html:sub(1, position - 1) .. css .. html:sub(position)
  elseif has_css and not has_script then
    local position = assert(html:find(css, 1, true)) + #css - 1
    patched = html:sub(1, position) .. script .. html:sub(position + 1)
  else
    local position = html:find("</head>", 1, true)
    if not position then
      return fail("cannot find injection point in: " .. path, options)
    end
    patched = html:sub(1, position - 1) .. css .. script .. html:sub(position)
  end

  return write_html(path, patched, function(verified)
    return verified:find(css, 1, true) ~= nil and verified:find(script, 1, true) ~= nil
  end, options)
end

local function patch_toc_sidebar(p, options)
  if not copy_if_changed(p.toc_dir .. "/toc-sidebar.js", p.static_dir .. "/toc-sidebar.js", options) then
    return false
  end
  if not copy_if_changed(p.toc_dir .. "/toc-sidebar.css", p.static_dir .. "/toc-sidebar.css", options) then
    return false
  end
  return patch_toc_html(p.out_html, options)
end

local function patch_link_handler(p, options)
  if not copy_if_changed(p.mkdp_dir .. "/links.js", p.static_dir .. "/links.js", options) then
    return false
  end
  return inject_html(
    p.out_html,
    "/_static/links.js",
    "</head>",
    '<script src="/_static/links.js" defer></script></head>',
    options
  )
end

local function patch_route_fix(p, options)
  if not copy_if_changed(p.mkdp_dir .. "/route-fix.js", p.static_dir .. "/route-fix.js", options) then
    return false
  end
  return inject_html(
    p.out_html,
    "/_static/route-fix.js",
    "<head>",
    '<head><script src="/_static/route-fix.js"></script>',
    options
  )
end

function M.patch_all(options)
  local p = paths(options)
  if vim.fn.isdirectory(p.static_dir) ~= 1 then
    return fail("target directory is missing: " .. p.static_dir, options)
  end
  if not require_file(p.out_html, "target", options) then
    return false
  end
  if not protect_index_html(p.plugin_dir, options) then
    return false
  end
  return patch_toc_sidebar(p, options) and patch_link_handler(p, options) and patch_route_fix(p, options)
end

function M.build(plugin, options)
  local missing = commands.first_missing({ "sh", "node", "npx" })
  if missing then
    notify("Markdown Preview build requires `" .. missing .. "` in PATH", vim.log.levels.ERROR, options)
    return false
  end

  local install = { "sh", "-c", "cd " .. vim.fn.shellescape(plugin.dir) .. "/app && npx --yes yarn install" }
  local ok, detail = run_system(install, options)
  if not ok then
    local suffix = type(detail) == "number" and "exit " .. detail or detail
    notify("Markdown Preview: Yarn install failed (" .. suffix .. "); patches were not applied", vim.log.levels.ERROR, options)
    return false
  end

  options = vim.tbl_extend("force", options or {}, { plugin_dir = options and options.plugin_dir or plugin.dir })
  return M.patch_all(options)
end

return M
