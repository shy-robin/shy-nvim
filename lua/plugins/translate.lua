return {
  "uga-rosa/translate.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      output = "split",
    },
    preset = {
      output = {
        split = {
          append = false,
        },
      },
    },
  },
  keys = {
    {
      "<leader>tz",
      "<cmd>Translate zh<cr>",
      desc = "Translate to Chinese",
      mode = "v",
    },
    {
      "<leader>te",
      "<cmd>Translate en<cr>",
      desc = "Translate to English",
      mode = "v",
    },
  },
}
