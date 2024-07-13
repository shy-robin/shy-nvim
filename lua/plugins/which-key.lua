return {
  "folke/which-key.nvim",
  opts = {
    win = {
      border = "rounded",
    },
    spec = {
      {
        "<leader>D",
        group = "+diffview",
      },
      {
        "<leader>C",
        group = "+coc",
      },
      {
        "<leader>ca",
        group = "+code-action",
      },
      {
        "<leader>cb",
        group = "+comment-box",
      },
      {
        "<leader>cs",
        group = "+snippets",
      },
      {
        "<leader>Ct",
        group = "+translator",
      },
      {
        "<leader>t",
        group = "+tabs/terminal",
      },
      {
        "<leader>to",
        group = "+open",
      },
      {
        "<leader>m",
        group = "+marks",
      },
      {
        "<leader>md",
        group = "+delete",
      },
      {
        "<leader>r",
        group = "+refactor",
      },
    },
    modes = {
      -- terminal 模式下禁用，否则按 esc 无法退出一些功能
      t = false,
    },
    icons = {
      rules = false,
    },
  },
  config = function(_, opts)
    local wk = require("which-key")

    -- local presets = require("which-key.plugins.presets")
    -- -- 设置 operator
    -- presets.operators["m"] = "Marks"
    -- presets.operators["t"] = "Tabs"

    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
