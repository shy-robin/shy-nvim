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
      {
        "<leader>p",
        group = "+picgo",
      },
      {
        "<leader>a",
        group = "+ai",
      },
    },
    triggers = {
      -- terminal 模式下禁用，否则按 esc 无法退出一些功能
      { "<auto>", mode = "nixsoc" },
    },
    icons = {
      rules = false,
    },
  },
}
