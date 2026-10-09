return {
  "folke/which-key.nvim",
  opts = {
    win = {
      border = "rounded",
    },
    spec = {
      {
        "<leader>D",
        group = "Diff / Database",
      },
      {
        "<leader>Dc",
        group = "Conflicts",
      },
      {
        "<leader>cb",
        group = "Comment Boxes",
      },
      {
        "<leader>cs",
        group = "Snippets",
      },
      {
        "<leader>t",
        group = "Tabs / Terminals / TODO",
        mode = "n",
      },
      {
        "<leader>t",
        group = "Translate",
        mode = "v",
      },
      {
        "<leader>to",
        group = "Open Terminal",
      },
      {
        "<leader>m",
        group = "Marks",
      },
      {
        "<leader>md",
        group = "Delete Marks",
      },
      {
        "<leader>r",
        group = "Reload",
      },
      {
        "<leader>p",
        group = "Images",
      },
      {
        "<leader>a",
        group = "AI",
      },
      {
        "<leader>l",
        group = "Lazy",
      },
      {
        "<leader>as",
        group = "Supermaven",
      },
      {
        "<leader>O",
        group = "Org / Outline",
      },
      {
        "<leader>o",
        group = "Org",
      },
      {
        "<leader>ob",
        group = "Babel",
      },
      {
        "<leader>od",
        group = "Timestamp",
      },
      {
        "<leader>oi",
        group = "Insert",
      },
      {
        "<leader>ol",
        group = "Links",
      },
      {
        "<leader>on",
        group = "Notes",
      },
      {
        "<leader>ox",
        group = "Clock / Effort",
      },
      {
        "<leader>n",
        group = "Org Roam",
      },
      {
        "<leader>na",
        group = "Aliases",
      },
      {
        "<leader>no",
        group = "Origin",
      },
      {
        "<leader>nd",
        group = "Daily Notes",
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
