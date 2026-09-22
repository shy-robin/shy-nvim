local function git_branches()
  local branches = vim.fn.systemlist({
    "git",
    "for-each-ref",
    "--format=%(refname:short)",
    "refs/heads",
    "refs/remotes",
  })

  branches = vim.tbl_filter(function(branch)
    return branch ~= "" and not branch:match("/HEAD$")
  end, branches)

  return branches
end

local function select_branch(prompt, on_select)
  local branches = git_branches()

  require("fzf-lua").fzf_exec(branches, {
    prompt = prompt,
    actions = {
      ["default"] = function(selected)
        local branch = selected[1]
        if branch then
          on_select(branch)
        end
      end,
    },
  })
end

local function diff_with_branch()
  select_branch("Diff with branch> ", function(branch)
    vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(branch) .. "...HEAD")
  end)
end

local function diff_between_branches()
  select_branch("Base branch> ", function(base)
    vim.schedule(function()
      select_branch("Compare branch> ", function(compare)
        if base == compare then
          vim.notify("请选择两个不同的分支", vim.log.levels.WARN)
          return
        end

        local range = vim.fn.fnameescape(base) .. "..." .. vim.fn.fnameescape(compare)
        vim.cmd("DiffviewOpen " .. range)
      end)
    end)
  end)
end

local function resize_file_panel(delta)
  local win = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(win)
  vim.api.nvim_win_set_width(win, math.max(20, width + delta))
end

return {
  "sindrets/diffview.nvim",
  event = "VeryLazy",
  config = function(_, opts)
    require("diffview").setup(opts)
    require("util.diffview_review").setup()
  end,
  opts = {
    hooks = {
      diff_buf_win_enter = function(...)
        require("util.diffview_review").enter(...)
      end,
    },
    view = {
      default = {
        winbar_info = true,
      },
      file_history = {
        winbar_info = true,
      },
    },
    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = false,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 38,
        win_opts = {
          number = false,
          relativenumber = false,
          cursorline = true,
          signcolumn = "no",
        },
      },
    },
    commit_log_panel = {
      win_config = {
        type = "split",
        position = "bottom",
        height = 12,
      },
    },
    keymaps = {
      file_panel = {
        {
          "n",
          "wl",
          function()
            resize_file_panel(10)
          end,
          { desc = "Increase the Diffview file panel width" },
        },
        {
          "n",
          "wh",
          function()
            resize_file_panel(-10)
          end,
          { desc = "Decrease the Diffview file panel width" },
        },
        {
          "n",
          "<leader>e",
          function()
            local actions = require("diffview.actions")
            return actions.toggle_files()
          end,
          { desc = "Toggle the Diffview file panel" },
        },
      },
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
      "<leader>DB",
      diff_between_branches,
      desc = "Diffview: compare two branches",
    },
    {
      "<leader>Dr",
      diff_with_branch,
      desc = "Diffview: select branch",
    },
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
