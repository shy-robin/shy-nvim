return {
  "iamcco/markdown-preview.nvim",
  event = "VeryLazy",
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  ft = "markdown",
  lazy = true,
  keys = { { "gm", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" } },
}
