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
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = "^1.0.0",
    },
  },
  event = "VeryLazy",
  keys = {
    -- 自定义查询，支持增加筛选参数
    {
      "<leader>/",
      function()
        require("telescope").extensions.live_grep_args.live_grep_args()
      end,
      desc = "Grep with Args (Root Dir)",
    },
    -- 这里的 root dir 是指当前 buffer 所在的根目录
    -- { "<leader>sf", require("lazyvim.util").telescope("files"), desc = "Find Files (root dir)" },
    -- 这里的 cwd 是指用 vim 进入编辑所在的目录
    -- { "<leader>sF", require("lazyvim.util").telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
    -- { "<leader>?", require("lazyvim.util").telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
    -- {
    --   "<leader>sg",
    --   function()
    --     require("telescope").extensions.live_grep_args.live_grep_args()
    --   end,
    --   desc = "Live Grep Args",
    -- },
    -- git
    -- { "<leader>gc", false },
    -- { "<leader>gs", false },
    -- { "<leader>gfc", "<cmd>Telescope git_commits<CR>", desc = "Git Find Commits" },
    -- { "<leader>gfs", "<cmd>Telescope git_status<CR>", desc = "Git Find Status" },
  },
  opts = function()
    local actions = require("telescope.actions")

    local find_files_no_ignore = function()
      local action_state = require("telescope.actions.state")
      local line = action_state.get_current_line()
      LazyVim.pick("find_files", { no_ignore = true, default_text = line })()
    end
    local find_files_with_hidden = function()
      local action_state = require("telescope.actions.state")
      local line = action_state.get_current_line()
      LazyVim.pick("find_files", { hidden = true, default_text = line })()
    end

    local function find_command()
      if 1 == vim.fn.executable("rg") then
        return { "rg", "--files", "--color", "never", "-g", "!.git" }
      elseif 1 == vim.fn.executable("fd") then
        return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
      elseif 1 == vim.fn.executable("fdfind") then
        return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
      elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
        return { "find", ".", "-type", "f" }
      elseif 1 == vim.fn.executable("where") then
        return { "where", "/r", ".", "*" }
      end
    end

    return {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " 󱞩 ",
        entry_prefix = "   ",
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
        -- open files in the first window that is an actual file.
        -- use the current window if no other window is available.
        get_selection_window = function()
          local wins = vim.api.nvim_list_wins()
          table.insert(wins, 1, vim.api.nvim_get_current_win())
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "" then
              return win
            end
          end
          return 0
        end,
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
            -- 切换为查询被忽略的文件（如 node_modules/ 下的文件））
            ["<C-i>"] = find_files_no_ignore,
            -- 切换为查询被隐藏的文件（如 .git/ 下的文件）
            ["<C-u>"] = find_files_with_hidden,
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
        find_files = {
          find_command = find_command,
          hidden = true,
        },
        live_grep = {
          mappings = {},
        },
      },
      extensions = {
        live_grep_args = {
          auto_quoting = true, -- enable/disable auto-quoting
          mappings = {
            i = {
              ["<C-y>"] = require("telescope-live-grep-args.actions").quote_prompt(),
              -- 搜索包含 ignore 文件的内容
              ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " --no-ignore " }),
              --iglob 通常表示启用广义匹配（glob matching），并且可能是“不区分大小写”（case insensitive）匹配的意思
              --例如：**/bar/**，这是一个 glob 模式，表示在任何层级的目录中���找名为 bar 的目录
              ["<C-g>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " --iglob " }),
              -- freeze the current list and start a fuzzy search in the frozen list
              ["<C-space>"] = actions.to_fuzzy_refine,
              -- 切换为查询所在目录下的字符
              ["<C-f>"] = ts_select_dir_for_grep,
            },
            n = {
              ["<C-f>"] = ts_select_dir_for_grep,
            },
          },
        },
      },
    }
  end,
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("file_browser")
    telescope.load_extension("live_grep_args")
  end,
}
