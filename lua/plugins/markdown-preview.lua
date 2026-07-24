local markdown_preview = require("util.markdown_preview")

local function hook_options(plugin)
  return { plugin_dir = assert(plugin and plugin.dir, "Markdown Preview hook requires Lazy plugin.dir") }
end

local function fail_hook(name)
  error("Markdown Preview " .. name .. " failed; see the earlier notification for remediation", 0)
end

return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function(plugin)
    if not markdown_preview.build(plugin, hook_options(plugin)) then
      fail_hook("build")
    end
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
  config = function(plugin)
    if not markdown_preview.patch_all(hook_options(plugin)) then
      fail_hook("configuration patch")
    end
  end,
  ft = { "markdown" },
  keys = {
    {
      "gom",
      function()
        require("util.mkdp").toggle()
      end,
      desc = "Markdown Preview Toggle",
    },
    {
      "goM",
      function()
        require("util.mkdp").pick()
      end,
      desc = "Markdown Preview List",
    },
  },
}
