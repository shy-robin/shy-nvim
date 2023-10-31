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
        {
          "n",
          "<leader>cO",
          false,
        },
        {
          "n",
          "<leader>dcO",
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
          "<leader>dcT",
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
          "<leader>dcB",
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
          "<leader>dcA",
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
          "<leader>dcX",
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
