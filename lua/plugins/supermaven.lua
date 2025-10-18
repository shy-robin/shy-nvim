return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
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
    -- 只有当这个函数返回 false 时，Supermaven 才会运行。
    -- 如果返回 true，则禁用。
    condition = function()
      -- 检查当前缓冲区是否设置了 'bigfile' 标志
      return vim.b.bigfile == true
    end,
  },
}
