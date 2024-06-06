return {
  "LudoPinelli/comment-box.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>cbb",
      "<cmd>CBccbox<cr>",
      silent = true,
      desc = "Comment Box Centered",
      mode = { "n", "v" }
    },
    {
      "<leader>cba",
      "<cmd>CBacbox<cr>",
      silent = true,
      desc = "Comment Box Adapted",
      mode = { "n", "v" }
    },
    {
      "<leader>cbl",
      "<cmd>CBccline<cr>",
      silent = true,
      desc = "Comment Box Line",
      mode = { "n", "v" }
    },
    {
      "<leader>cbd",
      "<cmd>CBd<cr>",
      silent = true,
      desc = "Comment Box Delete",
      mode = { "n", "v" }
    },
  }
}
