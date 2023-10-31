-- see: https://github.com/nvim-telescope/telescope.nvim/issues/2201
local ts_select_dir_for_grep = function(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local fb = require("telescope").extensions.file_browser
  local live_grep = require("telescope.builtin").live_grep
  local current_line = action_state.get_current_line()

  fb.file_browser({
    files = false,
    depth = false,
    attach_mappings = function(prompt_bufnr)
      require("telescope.actions").select_default:replace(function()
        local entry_path = action_state.get_selected_entry().Path
        local dir = entry_path:is_dir() and entry_path or entry_path:parent()
        local relative = dir:make_relative(vim.fn.getcwd())
        local absolute = dir:absolute()

        live_grep({
          results_title = relative .. "/",
          cwd = absolute,
          default_text = current_line,
        })
      end)

      return true
    end,
  })
end

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
  },
  event = "VeryLazy",
  keys = {
    -- 这里的 root dir 是指当前 buffer 所在的根目录
    { "<leader>sf", require("lazyvim.util").telescope("files"), desc = "Find Files (root dir)" },
    -- 这里的 cwd 是指用 vim 进入编辑所在的目录
    { "<leader>sF", require("lazyvim.util").telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
    { "<leader>?", require("lazyvim.util").telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
    {
      "<leader>sg",
      function()
        require("telescope").extensions.live_grep_args.live_grep_args()
      end,
      desc = "Live Grep Args",
    },
    -- git
    { "<leader>gc", false },
    { "<leader>gs", false },
    { "<leader>gfc", "<cmd>Telescope git_commits<CR>", desc = "Git Find Commits" },
    { "<leader>gfs", "<cmd>Telescope git_status<CR>", desc = "Git Find Status" },
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
          ["<C-a>"] = function()
            local action_state = require("telescope.actions.state")
            local line = action_state.get_current_line()
            -- show all files
            require("lazyvim.util").telescope("find_files", { no_ignore = true, hidden = true, default_text = line })()
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
          ["<C-a>"] = function()
            local action_state = require("telescope.actions.state")
            local line = action_state.get_current_line()
            -- find all files
            require("lazyvim.util").telescope("find_files", { no_ignore = true, hidden = true, default_text = line })()
          end,
        },
      },
      preview = {
        mime_hook = function(filepath, bufnr, opts)
          local is_image = function(filepath)
            local image_extensions = { "png", "jpg" } -- Supported image formats
            local split_path = vim.split(filepath:lower(), ".", { plain = true })
            local extension = split_path[#split_path]
            return vim.tbl_contains(image_extensions, extension)
          end
          if is_image(filepath) then
            local term = vim.api.nvim_open_term(bufnr, {})
            local function send_output(_, data, _)
              for _, d in ipairs(data) do
                vim.api.nvim_chan_send(term, d .. "\r\n")
              end
            end
            vim.fn.jobstart({
              "catimg",
              filepath, -- Terminal image viewer command
            }, { on_stdout = send_output, stdout_buffered = true, pty = true })
          else
            require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
          end
        end,
      },
    },
    pickers = {
      live_grep = {
        mappings = {
          i = {
            ["<C-f>"] = ts_select_dir_for_grep,
          },
          n = {
            ["<C-f>"] = ts_select_dir_for_grep,
          },
        },
      },
    },
    extensions = {
      live_grep_args = {
        auto_quoting = true,
        mappings = {
          i = {
            ["<C-y>"] = function(...)
              return require("telescope-live-grep-args.actions").quote_prompt()(...)
            end,
            ["<C-i>"] = function(...)
              return require("telescope-live-grep-args.actions").quote_prompt({ postfix = " --iglob " })(...)
            end,
          },
        },
      },
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("file_browser")
    telescope.load_extension("live_grep_args")
  end,
}
