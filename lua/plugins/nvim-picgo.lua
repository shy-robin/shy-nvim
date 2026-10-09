return {
  "askfiy/nvim-picgo",
  keys = {
    {
      "<leader>pp",
      "<cmd>lua require'nvim-picgo'.upload_clipboard()<cr>",
      desc = "Upload Clipboard Image",
      silent = true,
    },
    { "<leader>pP", "<cmd>lua require'nvim-picgo'.upload_imagefile()<cr>", desc = "Upload Image File", silent = true },
  },
}
