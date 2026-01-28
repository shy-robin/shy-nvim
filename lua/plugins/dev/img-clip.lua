return {
  "HakonHarnes/img-clip.nvim",
  
  opts = {
    default = {
      drag_and_drop = {
        -- 在终端缓冲区和 cmdline 模式下禁用，避免粘贴文字时报错
        enabled = function()
          return vim.bo.buftype ~= "terminal" and vim.fn.mode() ~= "c"
        end,
      },
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
