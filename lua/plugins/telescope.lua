return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  keys = {
    -- 这里的 root dir 是指当前 buffer 所在的根目录
    { "<leader>sf", require("lazyvim.util").telescope("files"), desc = "Find Files (root dir)" },
    -- 这里的 cwd 是指用 vim 进入编辑所在的目录
    { "<leader>sF", require("lazyvim.util").telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
    { "<leader>?", require("lazyvim.util").telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
  },
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
