-- close tree automatically when open file
-- local function edit_or_open()
--   local api = require("nvim-tree.api")
--   local node = api.tree.get_node_under_cursor()
--
--   if node.nodes ~= nil then
--     -- expand or collapse folder
--     api.node.open.edit()
--   else
--     -- open file
--     api.node.open.edit()
--     -- Close the tree if file was opened
--     api.tree.close()
--   end
-- end

-- open as vsplit on current node
local function vsplit_preview()
  local api = require("nvim-tree.api")
  local node = api.tree.get_node_under_cursor()

  if node.nodes ~= nil then
    -- expand or collapse folder
    api.node.open.edit()
  else
    -- open file as vsplit
    api.node.open.vertical()
  end

  -- Finally refocus on tree if it was lost
  api.tree.focus()
end

-- 参考: <https://www.reddit.com/r/neovim/comments/xj784v/comment/ipbxysp/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button>
-- 判断当前节点是文件夹则在这个文件夹下查询，否则到父目录下查询
local function grep_at_current_tree_node()
  local api = require("nvim-tree.api")
  local node = api.tree.get_node_under_cursor()

  if not node then
    return
  end

  local path = node.absolute_path or uv.cwd()
  if node.type ~= "directory" and node.parent then
    path = node.parent.absolute_path
  end

  require("fzf-lua").live_grep({
    cwd = path,
    prompt = string.format("[%s] ", vim.fs.basename(path)),
  })
end

local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")
  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  local set = vim.keymap.set

  -- default mappings
  -- api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  set("n", "?", api.tree.toggle_help, opts("Help"))
  set("n", "l", api.node.open.edit, opts("Edit Or Open"))
  set("n", "L", vsplit_preview, opts("Vsplit Preview"))
  set("n", "h", api.node.navigate.parent_close, opts("Close"))

  -- split
  set("n", "wr", api.node.open.vertical, opts("Open: Split Right"))
  set("n", "wb", api.node.open.horizontal, opts("Open: Split Bottom"))

  set("n", "i", api.node.show_info_popup, opts("Info"))
  set("n", "gr", api.tree.change_root_to_node, opts("Change Root To Node"))
  set("n", "gp", api.tree.change_root_to_parent, opts("Change Root To Parent"))

  -- copy
  set("n", "yy", api.fs.copy.node, opts("Copy"))
  set("n", "yp", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
  set("n", "yP", api.fs.copy.relative_path, opts("Copy Relative Path"))
  set("n", "yn", api.fs.copy.filename, opts("Copy Name"))

  -- rename
  set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
  set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
  set("n", "r", api.fs.rename, opts("Rename"))

  -- open
  set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
  set("n", "<cr>", api.node.open.edit, opts("Open"))
  set("n", "<tab>", api.node.open.preview, opts("Open: Preview"))
  set("n", "o", api.node.open.edit, opts("Open"))
  set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))

  -- sibling navigating
  set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
  set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
  set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
  set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))

  -- fold
  set("n", "E", api.tree.expand_all, opts("Expand All"))
  set("n", "W", api.tree.collapse_all, opts("Collapse All"))

  set("n", ".", api.node.run.cmd, opts("Run Command"))
  set("n", "a", api.fs.create, opts("Create"))
  set("n", "d", api.fs.remove, opts("Delete"))
  set("n", "D", api.fs.trash, opts("Trash"))
  set("n", "x", api.fs.cut, opts("Cut"))
  set("n", "p", api.fs.paste, opts("Paste"))
  set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
  set("n", "q", api.tree.close, opts("Close"))
  set("n", "R", api.tree.reload, opts("Refresh"))
  set("n", "s", api.node.run.system, opts("Run System"))
  set("n", "S", api.tree.search_node, opts("Search"))

  -- bookmarked
  set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
  set("n", "bd", api.marks.bulk.delete, opts("Delete Bookmarked"))
  set("n", "bt", api.marks.bulk.trash, opts("Trash Bookmarked"))
  set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))

  -- filter
  set("n", "f", api.live_filter.start, opts("Filter"))
  set("n", "F", api.live_filter.clear, opts("Clean Filter"))
  set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle Filter: No Buffer"))
  set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Filter: Git Clean"))
  set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
  set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
  set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Filter: Hidden"))

  -- git
  set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
  set("n", "]c", api.node.navigate.git.next, opts("Next Git"))

  -- diagnostics
  set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostics"))
  set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostics"))

  -- resize
  set("n", "wl", "<cmd>NvimTreeResize +10<cr>", opts("Increase Width"))
  set("n", "wh", "<cmd>NvimTreeResize -10<cr>", opts("Decrease Width"))

  -- grep in directory
  set("n", "<C-f>", grep_at_current_tree_node, opts("Grep Current Node"))
end

return {
  "nvim-tree/nvim-tree.lua",
  event = "VeryLazy",
  init = function()
    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true
  end,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer NvimTree (root dir)", silent = true },
  },
  opts = {
    sort_by = "case_sensitive",
    renderer = {
      special_files = {
        "README.md",
        "readme.md",
        "package.json",
      },
      highlight_git = true,
      highlight_diagnostics = true,
      highlight_opened_files = "name",
      highlight_bookmarks = "name",
      indent_markers = {
        enable = true,
      },
      icons = {
        glyphs = {
          folder = {
            default = "󰉋",
            open = "󰝰",
          },
          git = {
            unstaged = "󰄱",
            staged = "",
            unmerged = "",
            renamed = "󰁕",
            untracked = "",
            deleted = "✖",
            ignored = "",
          },
        },
      },
    },
    filters = {
      dotfiles = true,
    },
    diagnostics = {
      enable = true,
    },
    modified = {
      enable = true,
    },
    actions = {
      file_popup = {
        open_win_config = {
          border = "rounded",
        },
      },
    },
    update_focused_file = {
      enable = true,
    },
    on_attach = my_on_attach,
    view = {
      centralize_selection = true,
    },
  },
}
