-- Run through scripts/check.sh. No assertion in this file runs a real external command.
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local commands = require("util.external_commands")
local markdown = require("util.markdown_preview")

local function eq(actual, expected, message)
  assert(vim.deep_equal(actual, expected), string.format(
    "%s: expected %s, got %s",
    message,
    vim.inspect(expected),
    vim.inspect(actual)
  ))
end

local function match(actual, expected, message)
  assert(type(actual) == "string" and actual:find(expected, 1, true), string.format(
    "%s: expected %q in %s",
    message,
    expected,
    vim.inspect(actual)
  ))
end

local function with_restore(restore, callback)
  local ok, err = xpcall(callback, debug.traceback)
  restore()
  assert(ok, err)
end

local function with_value(object, key, value, callback)
  local original = object[key]
  object[key] = value
  with_restore(function()
    object[key] = original
  end, callback)
end

local function with_executables(available, callback)
  with_value(vim.fn, "executable", function(command)
    return available[command] and 1 or 0
  end, callback)
end

local function with_temp(callback)
  local temp = vim.fn.tempname()
  vim.fn.mkdir(temp, "p")
  with_restore(function()
    vim.fn.delete(temp, "rf")
  end, function()
    callback(temp)
  end)
end

local function write(path, lines)
  assert(vim.fn.writefile(lines, path) == 0, "cannot write fixture: " .. path)
end

local function create_checkout(temp, git_kind)
  local plugin_dir = temp .. "/plugin"
  local config_dir = temp .. "/config"
  vim.fn.mkdir(plugin_dir .. "/app/_static", "p")
  vim.fn.mkdir(plugin_dir .. "/app/out", "p")
  vim.fn.mkdir(config_dir .. "/assets/mkdp-toc", "p")
  vim.fn.mkdir(config_dir .. "/assets/mkdp", "p")
  write(plugin_dir .. "/app/out/index.html", { "<html><head></head><body></body></html>" })
  write(config_dir .. "/assets/mkdp-toc/toc-sidebar.js", { "toc script" })
  write(config_dir .. "/assets/mkdp-toc/toc-sidebar.css", { "toc style" })
  write(config_dir .. "/assets/mkdp/links.js", { "links" })
  write(config_dir .. "/assets/mkdp/route-fix.js", { "route" })
  if git_kind == "directory" then
    vim.fn.mkdir(plugin_dir .. "/.git", "p")
  elseif git_kind == "file" then
    write(plugin_dir .. "/.git", { "gitdir: /tmp/markdown-preview-worktree" })
  end
  return plugin_dir, config_dir
end

local function contents(path)
  return table.concat(vim.fn.readfile(path), "\n")
end

local function markdown_plugin_spec()
  return dofile(vim.fn.getcwd() .. "/lua/plugins/markdown-preview.lua")
end

with_executables({ du = true }, function()
  eq(
    commands.du_command("/tmp/project", "Darwin"),
    { "du", "-A", "-s", "-k", "/tmp/project" },
    "Darwin directory sizes use BSD apparent-size flags"
  )
  eq(
    commands.du_command("/tmp/project", "Linux"),
    { "du", "--apparent-size", "--summarize", "--block-size=1K", "/tmp/project" },
    "non-macOS directory sizes use GNU apparent-size flags"
  )
end)

with_executables({ sips = true, identify = true }, function()
  eq(
    commands.image_command("/tmp/photo.png", "Darwin"),
    { "sips", "-g", "pixelWidth", "-g", "pixelHeight", "/tmp/photo.png" },
    "macOS prefers sips for image dimensions"
  )
  eq(
    commands.image_command("/tmp/photo.png", "Linux"),
    { "identify", "-format", "%w %h", "/tmp/photo.png" },
    "non-macOS uses ImageMagick identify"
  )
end)

with_executables({ identify = true }, function()
  eq(
    commands.image_command("/tmp/photo.png", "Darwin"),
    { "identify", "-format", "%w %h", "/tmp/photo.png" },
    "ImageMagick falls back when macOS sips is unavailable"
  )
end)

with_executables({}, function()
  eq(commands.image_command("/tmp/photo.png", "Linux"), nil, "missing image tools omit dimensions")
  eq(commands.du_command("/tmp/project", "Linux"), nil, "missing du does not attempt a process")
end)

eq(commands.parse_du_result({ code = 1, stdout = "42\t/tmp/project" }), nil, "nonzero du exits have no size")
eq(commands.parse_image_result("sips", { code = 1, stdout = "" }), nil, "nonzero sips exits have no dimensions")
eq(commands.parse_image_result("identify", { code = 0, stdout = "1920 1080" }), "1920x1080", "identify output parses dimensions")

local spawn_error
with_value(vim, "system", function()
  error("spawn failed")
end, function()
  local started = commands.safe_system({ "du", "--version" }, { text = true }, function(result, err)
    spawn_error = { result = result, err = err }
  end)
  eq(started, false, "process-spawn failures do not escape the UI callback")
end)
eq(spawn_error.result, nil, "process-spawn failures have no result")
match(spawn_error.err, "spawn failed", "process-spawn failures preserve the error")

local success_result
with_value(vim, "system", function(command, options, callback)
  eq(command, { "du", "--version" }, "safe_system passes the requested command")
  assert(options.text, "safe_system preserves process options")
  callback({ code = 0, stdout = "ok" })
  return {}
end, function()
  local started = commands.safe_system({ "du", "--version" }, { text = true }, function(result, err)
    success_result = { result = result, err = err }
  end)
  eq(started, true, "successful process creation reports started")
end)
eq(success_result, { result = { code = 0, stdout = "ok" }, err = nil }, "safe_system relays process output")

-- Lazy must receive thrown errors, not ignored false return values, and wrappers must
-- bind both hooks to the exact checkout Lazy supplies.
with_executables({}, function()
  local spec = markdown_plugin_spec()
  local notifications = {}
  with_value(vim, "notify", function(message)
    table.insert(notifications, message)
  end, function()
    local ok, err = pcall(spec.build, { dir = "/tmp/exact-markdown-preview" })
    assert(not ok, "Markdown Preview build wrapper must raise when its helper returns false")
    match(err, "Markdown Preview build failed", "build wrapper error is clear")
  end)
  match(notifications[1], "sh", "build helper notification remains actionable")
end)

with_restore(function() end, function()
  local original_build = markdown.build
  local original_patch_all = markdown.patch_all
  local calls = {}
  markdown.build = function(plugin, options)
    calls.build = { plugin = plugin, options = options }
    return true
  end
  markdown.patch_all = function(options)
    calls.config = options
    return true
  end
  with_restore(function()
    markdown.build = original_build
    markdown.patch_all = original_patch_all
  end, function()
    local spec = markdown_plugin_spec()
    local plugin = { dir = "/tmp/custom-lazy-checkout" }
    spec.build(plugin)
    spec.config(plugin)
    eq(calls.build.options.plugin_dir, plugin.dir, "build wrapper forwards Lazy checkout root")
    eq(calls.config.plugin_dir, plugin.dir, "config wrapper forwards Lazy checkout root")
  end)
end)

with_restore(function() end, function()
  local original_patch_all = markdown.patch_all
  markdown.patch_all = function()
    return false
  end
  with_restore(function()
    markdown.patch_all = original_patch_all
  end, function()
    local ok, err = pcall(markdown_plugin_spec().config, { dir = "/tmp/exact-markdown-preview" })
    assert(not ok, "Markdown Preview config wrapper must raise when its helper returns false")
    match(err, "Markdown Preview configuration patch failed", "config wrapper error is clear")
  end)
end)

local function assert_build_skips_patching(label, available, system)
  local patch_calls = 0
  local original_patch_all = markdown.patch_all
  markdown.patch_all = function()
    patch_calls = patch_calls + 1
    return true
  end
  with_restore(function()
    markdown.patch_all = original_patch_all
  end, function()
    with_executables(available, function()
      local result = markdown.build({ dir = "/tmp/markdown-preview.nvim" }, {
        system = system,
        plugin_dir = "/tmp/markdown-preview.nvim",
        notify = function() end,
      })
      eq(result, false, label .. " returns false before patching")
    end)
  end)
  eq(patch_calls, 0, label .. " never invokes patches")
end

assert_build_skips_patching("missing sh", { node = true, npx = true }, function()
  error("install must not run without sh")
end)
assert_build_skips_patching("missing node", { sh = true, npx = true }, function()
  error("install must not run without node")
end)
assert_build_skips_patching("missing npx", { sh = true, node = true }, function()
  error("install must not run without npx")
end)
assert_build_skips_patching("Yarn nonzero exit", { sh = true, node = true, npx = true }, function()
  return "install failed", 23
end)
assert_build_skips_patching("Yarn spawn failure", { sh = true, node = true, npx = true }, function()
  error("install spawn failed")
end)

local function assert_failed_build_leaves_checkout(label, available, system)
  with_temp(function(temp)
    local plugin_dir, config_dir = create_checkout(temp)
    local index_html = plugin_dir .. "/app/out/index.html"
    local original_patch_all = markdown.patch_all
    local patch_calls = 0
    markdown.patch_all = function(options)
      patch_calls = patch_calls + 1
      return original_patch_all(options)
    end
    with_restore(function()
      markdown.patch_all = original_patch_all
    end, function()
      with_executables(available, function()
        local result = markdown.build({ dir = plugin_dir }, {
          plugin_dir = plugin_dir,
          config_dir = config_dir,
          system = system,
          notify = function() end,
        })
        eq(result, false, label .. " fails")
      end)
    end)
    eq(patch_calls, 0, label .. " does not invoke patch_all")
    eq(contents(index_html), "<html><head></head><body></body></html>", label .. " leaves index.html unchanged")
    eq(vim.fn.filereadable(plugin_dir .. "/app/_static/toc-sidebar.js"), 0, label .. " creates no patch assets")
  end)
end

assert_failed_build_leaves_checkout("missing build prerequisite", { node = true, npx = true }, function()
  error("install must not run")
end)
assert_failed_build_leaves_checkout("Yarn failure", { sh = true, node = true, npx = true }, function()
  return "install failed", 23
end)

with_executables({ git = true }, function()
  with_temp(function(temp)
    local plugin_dir, config_dir = create_checkout(temp, "directory")
    local index_html = plugin_dir .. "/app/out/index.html"
    local calls = {}
    local patched = markdown.patch_all({
      plugin_dir = plugin_dir,
      config_dir = config_dir,
      system = function(command)
        table.insert(calls, command)
        assert(not contents(index_html):find("toc%-sidebar", 1, false), "index protection runs before HTML mutation")
        return "", 0
      end,
    })
    eq(patched, true, "protected directory checkout patches successfully")
    eq(calls, { { "git", "-C", plugin_dir, "update-index", "--skip-worktree", "app/out/index.html" } }, "directory checkout protects index first")
    local html = contents(index_html)
    assert(html:find("route%-fix", 1, false), "route patch remains applied")
    assert(html:find("links%.js", 1, false), "link patch remains applied")
    assert(html:find("toc%-sidebar%.css", 1, false), "TOC CSS remains applied")
    assert(html:find("toc%-sidebar%.js", 1, false), "TOC JS remains applied")
  end)

  with_temp(function(temp)
    local plugin_dir, config_dir = create_checkout(temp, "file")
    local patched = markdown.patch_all({
      plugin_dir = plugin_dir,
      config_dir = config_dir,
      system = function()
        return "", 0
      end,
    })
    eq(patched, true, "worktree .git file receives index protection")
  end)

  with_temp(function(temp)
    local plugin_dir, config_dir = create_checkout(temp, "directory")
    local index_html = plugin_dir .. "/app/out/index.html"
    local patched = markdown.patch_all({
      plugin_dir = plugin_dir,
      config_dir = config_dir,
      system = function()
        return "git failed", 1
      end,
      notify = function() end,
    })
    eq(patched, false, "index protection failure stops patching")
    eq(contents(index_html), "<html><head></head><body></body></html>", "failed protection leaves index.html unchanged")
  end)
end)

with_temp(function(temp)
  local plugin_dir, config_dir = create_checkout(temp)
  local original_readfile = vim.fn.readfile
  with_value(vim.fn, "readfile", function(path, ...)
    if path:find("toc%-sidebar%.js", 1, false) then
      error("simulated read failure")
    end
    return original_readfile(path, ...)
  end, function()
    local result = markdown.patch_all({
      plugin_dir = plugin_dir,
      config_dir = config_dir,
      notify = function() end,
    })
    eq(result, false, "read failures are reported instead of escaping")
  end)
end)

with_temp(function(temp)
  local plugin_dir, config_dir = create_checkout(temp)
  local target = plugin_dir .. "/app/_static/toc-sidebar.js"
  local original_readfile = vim.fn.readfile
  with_value(vim.fn, "readfile", function(path, ...)
    if path == target then
      error("simulated verification read failure")
    end
    return original_readfile(path, ...)
  end, function()
    local result = markdown.patch_all({
      plugin_dir = plugin_dir,
      config_dir = config_dir,
      notify = function() end,
    })
    eq(result, false, "verification read failures are reported instead of escaping")
  end)
end)

with_temp(function(temp)
  local plugin_dir, config_dir = create_checkout(temp)
  local index_html = plugin_dir .. "/app/out/index.html"
  write(index_html, {
    '<html><head><link rel="stylesheet" href="/_static/toc-sidebar.css"/></head><body></body></html>',
  })
  local patched = markdown.patch_all({ plugin_dir = plugin_dir, config_dir = config_dir })
  eq(patched, true, "TOC repair succeeds when only its script marker is missing")
  local html = contents(index_html)
  assert(html:find("toc%-sidebar%.css", 1, false), "TOC repair retains CSS")
  assert(html:find("toc%-sidebar%.js", 1, false), "TOC repair restores JS independently")
end)

local function find_key(spec, key)
  for _, mapping in ipairs(spec.keys) do
    if mapping[1] == key then
      return mapping
    end
  end
  error("missing mapping: " .. key)
end

local scissors = dofile(vim.fn.getcwd() .. "/lua/plugins/scissors.lua")
assert(scissors.opts.jsonFormatter == nil, "Scissors must not configure deprecated jsonFormatter")

with_executables({}, function()
  local floaterm = dofile(vim.fn.getcwd() .. "/lua/plugins/vim-floaterm.lua")
  for _, key in ipairs({ "<leader>tor", "<leader>y" }) do
    local mapping = find_key(floaterm, key)
    assert(type(mapping[2]) == "function", key .. " must guard its optional command")
    local notifications = {}
    with_value(vim, "notify", function(message)
      table.insert(notifications, message)
    end, function()
      with_value(vim, "cmd", function()
        error("unavailable optional terminal must not launch")
      end, function()
        mapping[2]()
      end)
    end)
    match(notifications[1], key == "<leader>tor" and "ranger" or "yazi", key .. " names the missing dependency")
  end
end)

with_executables({ ranger = true, yazi = true }, function()
  local floaterm = dofile(vim.fn.getcwd() .. "/lua/plugins/vim-floaterm.lua")
  for key, command in pairs({ ["<leader>tor"] = "FloatermNew ranger", ["<leader>y"] = "FloatermNew yazi" }) do
    local invoked
    with_value(vim, "cmd", function(value)
      invoked = value
    end, function()
      find_key(floaterm, key)[2]()
    end)
    eq(invoked, command, key .. " launches its available optional command")
  end
end)

print("OK external command guards handle platform, dependency, patch, and spawn failures")
