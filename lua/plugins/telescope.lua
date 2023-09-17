return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      prompt_prefix = "  ",
      selection_caret = " 󱞩 ",
      entry_prefix = "   ",
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
      },
      mappings = {
        i = {
          ["<C-h>"] = function(...)
            return require("telescope.actions").cycle_history_prev(...)
          end,
          ["<C-l>"] = function(...)
            return require("telescope.actions").cycle_history_next(...)
          end,
          ["<C-j>"] = function(...)
            return require("telescope.actions").move_selection_next(...)
          end,
          ["<C-k>"] = function(...)
            return require("telescope.actions").move_selection_previous(...)
          end,
          ["<C-n>"] = function(...)
            return require("telescope.actions").preview_scrolling_down(...)
          end,
          ["<C-p>"] = function(...)
            return require("telescope.actions").preview_scrolling_up(...)
          end,
        },
        n = {
          ["<C-h>"] = function(...)
            return require("telescope.actions").cycle_history_prev(...)
          end,
          ["<C-l>"] = function(...)
            return require("telescope.actions").cycle_history_next(...)
          end,
          ["<C-j>"] = function(...)
            return require("telescope.actions").move_selection_next(...)
          end,
          ["<C-k>"] = function(...)
            return require("telescope.actions").move_selection_previous(...)
          end,
          ["<C-n>"] = function(...)
            return require("telescope.actions").preview_scrolling_down(...)
          end,
          ["<C-p>"] = function(...)
            return require("telescope.actions").preview_scrolling_up(...)
          end,
        },
      },
    },
  },
}
