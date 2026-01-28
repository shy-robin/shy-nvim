return {
  "xiyaowong/transparent.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.transparent_groups =
      -- coc 弹窗未找到 highlight group ，暂时未清除
      vim.list_extend(vim.g.transparent_groups or {}, { "FloatBorder", "FloatermBorder", "NormalFloat" })
  end,
}
