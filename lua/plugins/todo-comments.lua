return {
  "folke/todo-comments.nvim",
  keys = {
    {
      "<leader>tj",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Next todo comment",
    },
    {
      "<leader>tk",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Previous todo comment",
    },
  },
}
