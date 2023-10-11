return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  event = "BufReadPre",
  keys = {
    {
      "<leader>fb",
      "<cmd>Telescope file_browser<cr>",
      noremap = true,
      silent = true,
      desc = "File Browser (cwd)",
    },
    {
      "<leader>fB",
      "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>",
      noremap = true,
      silent = true,
      desc = "File Browser (Current Buffer)",
    },
  },
}
