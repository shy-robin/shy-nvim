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

return {
  "iamcco/markdown-preview.nvim",
  event = "VeryLazy",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function(plugin)
    vim.fn.system({ "sh", "-c", "cd " .. vim.fn.shellescape(plugin.dir) .. "/app && npx --yes yarn install" })
    patch_toc_sidebar()
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
  end,
  ft = { "markdown" },
  keys = {
    { "gom", function() require("util.mkdp").toggle() end, desc = "Markdown Preview Toggle" },
  },
}
