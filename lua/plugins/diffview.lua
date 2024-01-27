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
          "<leader>Dck",
          function()
            local actions = require("diffview.actions")
            return actions.prev_conflict()
          end,
          { desc = "In the merge-tool: jump to the previous conflict" },
        },
        {
          "n",
          "<leader>Dcj",
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
          "<leader>Dco",
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
          "<leader>Dct",
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
          "<leader>Dcb",
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
          "<leader>Dca",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose("all")()
          end,
          { desc = "Choose all the versions of a conflict" },
        },
        {
          "n",
          "<leader>Dcx",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose("none")()
          end,
          { desc = "Delete the conflict region" },
        },
        {
          "n",
          "<leader>cO",
          false,
        },
        {
          "n",
          "<leader>DcO",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose_all("ours")()
          end,
          { desc = "Choose the OURS version of a conflict for the whole file" },
        },
        {
          "n",
          "<leader>cT",
          false,
        },
        {
          "n",
          "<leader>DcT",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose_all("theirs")()
          end,
          { desc = "Choose the THEIRS version of a conflict for the whole file" },
        },
        {
          "n",
          "<leader>cB",
          false,
        },
        {
          "n",
          "<leader>DcB",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose_all("base")()
          end,
          { desc = "Choose the BASE version of a conflict for the whole file" },
        },
        {
          "n",
          "<leader>cA",
          false,
        },
        {
          "n",
          "<leader>DcA",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose_all("all")()
          end,
          { desc = "Choose all the versions of a conflict for the whole file" },
        },
        {
          "n",
          "dX",
          false,
        },
        {
          "n",
          "<leader>DcX",
          function()
            local actions = require("diffview.actions")
            return actions.conflict_choose_all("none")()
          end,
          { desc = "Delete the conflict region for the whole file" },
        },
      },
    },
  },
  keys = {
    {
      "<leader>Dd",
      "<cmd>DiffviewOpen<cr>",
      desc = "DiffviewOpen",
    },
    {
      "<leader>Dq",
      "<cmd>tabclose<cr>",
      desc = "Diffview Quit",
    },
    {
      "<leader>Db",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "DiffviewFileHistory (Branch)",
    },
    {
      "<leader>Df",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "DiffviewFileHistory (Current File)",
    },
  },
}
