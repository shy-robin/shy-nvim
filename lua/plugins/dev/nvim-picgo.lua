return {
  "askfiy/nvim-picgo",
  
  keys = {
    { "<leader>pp", "<cmd>lua require'nvim-picgo'.upload_clipboard()<cr>", desc = "Clipboard", silent = true },
    { "<leader>pP", "<cmd>lua require'nvim-picgo'.upload_imagefile()<cr>", desc = "Path", silent = true },
  },
}
