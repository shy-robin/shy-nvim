return {
  "iamcco/markdown-preview.nvim",
  event = "VeryLazy",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_browser = ""
    vim.g.mkdp_echo_preview_url = true
    vim.g.mkdp_page_title = "「${name}」"
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_theme = "light"
  end,
  ft = { "markdown" },
  keys = { { "gom", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" } },
}
