local function patch_toc_sidebar()
  local plugin_dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
  local static_dir = plugin_dir .. "/app/_static"
  local out_html = plugin_dir .. "/app/out/index.html"
  local src_dir = vim.fn.stdpath("config") .. "/assets/mkdp-toc"

  if vim.fn.isdirectory(static_dir) == 0 or vim.fn.filereadable(out_html) == 0 then
    return
  end

  local function copy_if_changed(src, dst)
    if vim.fn.filereadable(src) == 0 then return end
    local src_lines = vim.fn.readfile(src, "b")
    if vim.fn.filereadable(dst) == 1 then
      local dst_lines = vim.fn.readfile(dst, "b")
      if vim.deep_equal(src_lines, dst_lines) then return end
    end
    vim.fn.writefile(src_lines, dst, "b")
  end

  copy_if_changed(src_dir .. "/toc-sidebar.js", static_dir .. "/toc-sidebar.js")
  copy_if_changed(src_dir .. "/toc-sidebar.css", static_dir .. "/toc-sidebar.css")

  local lines = vim.fn.readfile(out_html)
  if not lines or #lines == 0 then return end
  local html = table.concat(lines, "\n")
  if html:find("toc%-sidebar%.css", 1, false) then return end

  local inject = '<link rel="stylesheet" href="/_static/toc-sidebar.css"/>'
    .. '<script src="/_static/toc-sidebar.js" defer></script>'
  local patched, n = html:gsub("</head>", inject .. "</head>", 1)
  if n == 1 then
    vim.fn.writefile(vim.split(patched, "\n", { plain = true }), out_html)
  end
end

local function patch_link_handler()
  local plugin_dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
  local static_dir = plugin_dir .. "/app/_static"
  local out_html = plugin_dir .. "/app/out/index.html"
  local src = vim.fn.stdpath("config") .. "/assets/mkdp/links.js"

  if vim.fn.isdirectory(static_dir) == 0 or vim.fn.filereadable(out_html) == 0 then
    return
  end
  if vim.fn.filereadable(src) == 0 then
    return
  end

  -- 复制（变更才写）
  local dst = static_dir .. "/links.js"
  local src_lines = vim.fn.readfile(src, "b")
  if vim.fn.filereadable(dst) == 1 then
    local dst_lines = vim.fn.readfile(dst, "b")
    if not vim.deep_equal(src_lines, dst_lines) then
      vim.fn.writefile(src_lines, dst, "b")
    end
  else
    vim.fn.writefile(src_lines, dst, "b")
  end

  -- 注入（幂等）
  local lines = vim.fn.readfile(out_html)
  if not lines or #lines == 0 then
    return
  end
  local html = table.concat(lines, "\n")
  if html:find("/_static/links%.js", 1, false) then
    return
  end
  local inject = '<script src="/_static/links.js" defer></script>'
  local patched, n = html:gsub("</head>", inject .. "</head>", 1)
  if n == 1 then
    vim.fn.writefile(vim.split(patched, "\n", { plain = true }), out_html)
  end
end

local function patch_route_fix()
  local plugin_dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
  local static_dir = plugin_dir .. "/app/_static"
  local out_html = plugin_dir .. "/app/out/index.html"
  local src = vim.fn.stdpath("config") .. "/assets/mkdp/route-fix.js"

  if vim.fn.isdirectory(static_dir) == 0 or vim.fn.filereadable(out_html) == 0 then
    return
  end
  if vim.fn.filereadable(src) == 0 then
    return
  end

  -- 复制（变更才写）
  local dst = static_dir .. "/route-fix.js"
  local src_lines = vim.fn.readfile(src, "b")
  if vim.fn.filereadable(dst) == 1 then
    local dst_lines = vim.fn.readfile(dst, "b")
    if not vim.deep_equal(src_lines, dst_lines) then
      vim.fn.writefile(src_lines, dst, "b")
    end
  else
    vim.fn.writefile(src_lines, dst, "b")
  end

  -- 注入（幂等）。必须同步执行且早于前端 hydration，
  -- 故插在 <head> 顶部、不加 defer/async（与页面其它 head 脚本一致）。
  local lines = vim.fn.readfile(out_html)
  if not lines or #lines == 0 then
    return
  end
  local html = table.concat(lines, "\n")
  if html:find("/_static/route%-fix%.js", 1, false) then
    return
  end
  local inject = '<script src="/_static/route-fix.js"></script>'
  local patched, n = html:gsub("<head>", "<head>" .. inject, 1)
  if n == 1 then
    vim.fn.writefile(vim.split(patched, "\n", { plain = true }), out_html)
  end
end

-- 让 git 忽略我们对被跟踪文件 app/out/index.html 的注入改动。
-- 否则 lazy.nvim 更新前的 `git ls-files -m` 脏树检查会拒绝更新（status failed）。
-- skip-worktree 标记存于本地 .git/index，会被 x+I 重装清掉，故在 build 钩子里重设。
local function ignore_index_html_changes()
  local plugin_dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
  if vim.fn.isdirectory(plugin_dir .. "/.git") == 0 then
    return
  end
  vim.fn.system({ "git", "-C", plugin_dir, "update-index", "--skip-worktree", "app/out/index.html" })
end

return {
  "iamcco/markdown-preview.nvim",
  event = "VeryLazy",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function(plugin)
    vim.fn.system({ "sh", "-c", "cd " .. vim.fn.shellescape(plugin.dir) .. "/app && npx --yes yarn install" })
    patch_toc_sidebar()
    patch_link_handler()
    patch_route_fix()
    ignore_index_html_changes()
  end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    -- 全局注册 :MarkdownPreview* 命令，使其在任意 buffer 都可用。
    -- 含超长行的 markdown 会被识别为 bigfile（见 config/options.lua），
    -- 此时 filetype 不再是 markdown，但浏览器预览本身不占用 nvim 内存，
    -- 故让命令对所有 buffer 生效，bigfile 下 gom 仍能正常预览。
    vim.g.mkdp_command_for_global = 1
    vim.g.mkdp_browser = ""
    vim.g.mkdp_echo_preview_url = true
    vim.g.mkdp_page_title = "「${name}」"
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_theme = "light"
    -- 用官方钩子捕获每个 buffer 的精确预览 URL，并由管理器统一打开浏览器。
    vim.g.mkdp_browserfunc = "MkdpBrowserFunc"
    vim.cmd([[
      function! MkdpBrowserFunc(url) abort
        call luaeval('require("util.mkdp").browserfunc(_A)', a:url)
      endfunction
    ]])
  end,
  config = function()
    patch_toc_sidebar()
    patch_link_handler()
    patch_route_fix()
  end,
  ft = { "markdown" },
  keys = {
    { "gom", function() require("util.mkdp").toggle() end, desc = "Markdown Preview Toggle" },
    { "goM", function() require("util.mkdp").pick() end, desc = "Markdown Preview List" },
  },
}
