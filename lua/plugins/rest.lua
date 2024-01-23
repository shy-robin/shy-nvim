return {
  "rest-nvim/rest.nvim",
  event = "VeryLazy",
  dependencies = { { "nvim-lua/plenary.nvim" } },
  config = function()
    require("rest-nvim").setup({
      --- Get the same options from Packer setup
    })
  end,
  keys = {
    {
      "<leader>rr",
      "<Plug>RestNvim",
      silent = true,
      desc = "Rest Nvim Run",
    },
    {
      "<leader>rp",
      "<Plug>RestNvimPreview",
      silent = true,
      desc = "Rest Nvim Preview",
    },
    {
      "<leader>rl",
      "<Plug>RestNvimLast",
      silent = true,
      desc = "Rest Nvim Last",
    },
  },
}
