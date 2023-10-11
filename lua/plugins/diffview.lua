return {
  "sindrets/diffview.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>dd",
      "<cmd>DiffviewOpen<cr>",
      desc = "DiffviewOpen",
    },
    {
      "<leader>dc",
      "<cmd>tabclose<cr>",
      desc = "Diffview Close",
    },
    {
      "<leader>db",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "DiffviewFileHistory (Branch)",
    },
    {
      "<leader>df",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "DiffviewFileHistory (Current File)",
    },
  },
}
