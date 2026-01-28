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

local function edit_or_open()
  local api = require("nvim-tree.api")
  local node = api.tree.get_node_under_cursor()

  if not node then
    return
  end

  -- Prevent navigation up when pressing 'l' on the root node
  if node.nodes and node.parent == nil then
    return
  end

  api.node.open.edit()
end

local function get_image_info()
  local api = require("nvim-tree.api")
  local node = api.tree.get_node_under_cursor()

  if not node then
    return
  end

  if node.type ~= "file" then
    api.node.show_info_popup()
    return
  end

  local image_extensions =
    { "png", "jpg", "jpeg", "gif", "webp", "avif", "svg", "ico", "bmp", "pbm", "pgm", "ppm", "tiff", "tif" }
  local extension = node.extension and node.extension:lower() or ""
  local is_image = false
  for _, ext in ipairs(image_extensions) do
    if extension == ext then
      is_image = true
      break
    end
  end

  if not is_image then
    api.node.show_info_popup()
    return
  end

  local file_path = node.absolute_path
  local stat = node.fs_stat
  if not stat then
    stat = (vim.uv or vim.loop).fs_stat(file_path)
  end

  if not stat then
    api.node.show_info_popup()
    return
  end

  -- 尝试加载 nvim-tree 工具以保持一致的格式
  local status_utils, utils = pcall(require, "nvim-tree.utils")
  local format_size = function(bytes)
    if status_utils and utils.format_bytes then
      return utils.format_bytes(bytes)
    end
    -- 后备实现 (如果无法加载 utils)
    local units = { "B", "K", "M", "G", "T", "P", "E", "Z", "Y" }
    bytes = math.max(bytes, 0)
    local pow = math.floor((bytes and math.log(bytes) or 0) / math.log(1024))
    pow = math.min(pow, #units)
    local value = bytes / (1024 ^ pow)
    value = math.floor((value * 100) + 0.5) / 100
    pow = pow + 1
    if units[pow] == nil or pow == 1 then
      return bytes .. " " .. units[1]
    else
      return value .. " " .. units[pow] .. "i" .. units[1]
    end
  end

  local cmd = { "sips", "-g", "pixelWidth", "-g", "pixelHeight", file_path }
  -- 使用 pcall 避免 sips 失败导致错误
  local success, output = pcall(vim.fn.system, cmd)
  local width, height
  if success and output then
    width = output:match("pixelWidth: (%d+)")
    height = output:match("pixelHeight: (%d+)")
  end

  local lines = {}
  table.insert(lines, " fullpath: " .. file_path)
  table.insert(lines, " size:     " .. format_size(stat.size))
  table.insert(lines, " accessed: " .. os.date("%x %X", stat.atime.sec))
  table.insert(lines, " modified: " .. os.date("%x %X", stat.mtime.sec))
  table.insert(lines, " created:  " .. os.date("%x %X", stat.birthtime.sec))

  if width and height then
    table.insert(lines, " dimensions: " .. width .. "x" .. height)
  end

  -- 创建浮动窗口
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local max_width = 0
  for _, line in ipairs(lines) do
    if #line > max_width then
      max_width = #line
    end
  end

  local opts = {
    relative = "cursor",
    width = max_width + 1,
    height = #lines,
    col = 1,
    row = 1,
    style = "minimal",
    border = "rounded",
    noautocmd = true,
    zindex = 60,
  }

  -- 打开窗口但不聚焦 (enter=false)，保持焦点在树上
  local win = vim.api.nvim_open_win(buf, false, opts)

  -- 关闭窗口辅助函数
  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    -- 清除 buffer
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  -- 当在当前 buffer (nvim-tree) 中移动光标时自动关闭
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = 0, -- 当前 buffer (nvim-tree)
    callback = close_win,
    once = true,
  })

  -- 如果离开 buffer 或窗口也关闭
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    buffer = 0,
    callback = close_win,
    once = true,
  })

  -- Keymaps to close window (in case user somehow focuses it or wants to force close)
  -- Since we don't focus the window, these keys map to the tree buffer essentially,
  -- but we want standard tree navigation to close the popup implicitly via CursorMoved.
  -- We can map 'q' or 'Esc' in the tree buffer to close the popup IF it's open,
  -- but that's complex. Standard nvim-tree behavior is: move cursor closes it.
  -- So we rely on CursorMoved.
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
  set("n", "l", edit_or_open, opts("Edit Or Open"))
  set("n", "L", vsplit_preview, opts("Vsplit Preview"))
  set("n", "h", api.node.navigate.parent_close, opts("Close"))

  -- split
  set("n", "wr", api.node.open.vertical, opts("Open: Split Right"))
  set("n", "wb", api.node.open.horizontal, opts("Open: Split Bottom"))

  set("n", "i", get_image_info, opts("Image Info"))
  -- Change root directory (切换工作目录)
  set("n", "gr", api.tree.change_root_to_node, opts("Change Root To Node")) -- 进入当前目录
  set("n", "gp", api.tree.change_root_to_parent, opts("Change Root To Parent")) -- 返回上一级目录

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
        -- "README.md",
        -- "readme.md",
        -- "package.json",
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
      -- 当焦点文件切换时，更新 nvim-tree 的根目录
      -- update_root = true,
    },
    on_attach = my_on_attach,
    view = {
      centralize_selection = true,
    },
  },
}
