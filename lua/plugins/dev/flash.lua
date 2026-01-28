return {
  "folke/flash.nvim",
  opts = {
    label = {
      uppercase = false,
      rainbow = {
        enabled = true,
      },
    },
    modes = {
      char = {
        keys = {
          ";",
          ",",
        },
      },
    },
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      false,
    },
    {
      "S",
      mode = { "n", "o", "x" },
      false,
    },
    {
      "f",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "F",
      mode = { "n", "o", "x" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
  },
}
