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
      -- bigfile 标志（snacks.bigfile 等会设置）
      if vim.b.bigfile == true then
        return true
      end

      local buf = vim.api.nvim_get_current_buf()

      -- 特殊/只读 buffer：flutter 调试日志、各类 log/nofile
      -- 这些 buffer 行数会爆炸式增长，supermaven 上传必然超限报错
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("__FLUTTER_DEV_LOG__") then
        return true
      end
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      if ft == "log" or bt == "nofile" or bt == "terminal" then
        return true
      end

      -- 通用兜底：超大 buffer 一律跳过（supermaven 服务器本身也会拒收）
      if vim.api.nvim_buf_line_count(buf) > 20000 then
        return true
      end

      return false
    end,
  },
}
