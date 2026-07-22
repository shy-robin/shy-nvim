return {
  "xiyaowong/transparent.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.transparent_groups =
      vim.list_extend(vim.g.transparent_groups or {}, { "FloatBorder", "FloatermBorder", "NormalFloat" })
  end,
}
