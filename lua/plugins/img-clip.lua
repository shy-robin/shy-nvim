return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      drag_and_drop = {
        -- 在终端缓冲区中禁用，避免粘贴文字时报错
        enabled = function()
          return vim.bo.buftype ~= "terminal"
        end,
      },
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
