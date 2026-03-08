return {
  "chrisgrieser/nvim-scissors",
  keys = {
    {
      "<leader>csa",
      function()
        require("scissors").addNewSnippet()
      end,
      mode = { "n", "x" },
      desc = "Add Snippet",
    },
    {
      "<leader>cse",
      function()
        require("scissors").editSnippet()
      end,
      desc = "Edit Snippet",
    },
  },
  opts = {
    editSnippetPopup = {
      border = "rounded",
    },
    backdrop = {
      enabled = true,
      blend = 100,
    },
    snippetSelection = {
      picker = "snacks",
    },
    jsonFormatter = "jq",
  },
}
