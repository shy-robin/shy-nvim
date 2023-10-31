return {
  "sindrets/diffview.nvim",
  event = "VeryLazy",
  opts = {
    keymaps = {
      view = {
        {
          "n",
          "[x",
          false,
        },
        {
          "n",
          "]x",
          false,
        },
        {
          "n",
          "<leader>dck",
          function()
            local actions = require("diffview.actions")
            return actions.prev_conflict()
          end,
          { desc = "In the merge-tool: jump to the previous conflict" },
        },
        {
          "n",
          "<leader>dcj",
          function()
            local actions = require("diffview.actions")
            return actions.next_conflict()
          end,
          { desc = "In the merge-tool: jump to the next conflict" },
        },
        {
          "n",
          "<leader>co",
          false,
        },
        {
          "n",
          "<leader>dco",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose("ours")()
          end,
          { desc = "Choose the OURS version of a conflict" },
        },
        {
          "n",
          "<leader>ct",
          false,
        },
        {
          "n",
          "<leader>dct",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose("theirs")()
          end,
          { desc = "Choose the THEIRS version of a conflict" },
        },
        {
          "n",
          "<leader>cb",
          false,
        },
        {
          "n",
          "<leader>dcb",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose("base")()
          end,
          { desc = "Choose the BASE version of a conflict" },
        },
        {
          "n",
          "<leader>ca",
          false,
        },
        {
          "n",
          "<leader>dca",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose("all")()
          end,
          { desc = "Choose all the versions of a conflict" },
        },
        {
          "n",
          "<leader>dcx",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose("none")()
          end,
          { desc = "Delete the conflict region" },
        },
      },
    },
  },
  keys = {
    {
      "<leader>dd",
      "<cmd>DiffviewOpen<cr>",
      desc = "DiffviewOpen",
    },
    {
      "<leader>dq",
      "<cmd>tabclose<cr>",
      desc = "Diffview Quit",
    },
    {
      "<leader>db",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "DiffviewFileHistory (Branch)",
    },
    {
      "<leader>df",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "DiffviewFileHistory (Current File)",
    },
  },
}
