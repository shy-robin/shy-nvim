return {
  "ellisonleao/carbon-now.nvim",
  lazy = true,
  cmd = "CarbonNow",
  opts = {
    options = {
      theme = "one-dark",
      font_size = "14px",
      titlebar = "",
    },
  },
  keys = {
    {
      "<leader>cn",
      "<cmd>CarbonNow<cr>",
      desc = "Carbon Now",
      mode = { "v" },
      silent = true,
    },
  },
}
