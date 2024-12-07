return {
  "supermaven-inc/supermaven-nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>asl", "<cmd>SupermavenShowLog<cr>", desc = "Supermaven Show Log" },
    { "<leader>asr", "<cmd>SupermavenRestart<cr>", desc = "Supermaven Restart" },
  },
  opts = {
    keymaps = {
      accept_suggestion = "<C-y>",
      clear_suggestion = "<C-]>",
      accept_word = "<C-w>",
    },
  },
}
