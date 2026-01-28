return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = false,
      diagnostics = "coc",
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "center",
        },
      },
      buffer_close_icon = "󰅖",
      show_buffer_close_icons = false,
      show_close_icon = false,
    },
  },
  keys = {
    { "<leader>bh", "<cmd>bprevious<cr>", desc = "Prev Buffer" },
    { "<leader>bl", "<cmd>bnext<cr>", desc = "Next Buffer" },
    { "tt", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    { "tn", "<cmd>enew<cr>", desc = "New buffer" },
    { "tH", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
    { "tL", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
    { "tp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
    { "tP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    {
      "tw",
      function()
        require("mini.bufremove").delete(0, false)
      end,
      desc = "Delete Buffer",
    },
    {
      "tW",
      "<cmd>bd!<cr>",
      desc = "Delete Buffer (Force)",
    },
    {
      "to",
      "<cmd>BufferLineCloseOthers<cr>",
      "Delete other buffers",
    },
  },
}
