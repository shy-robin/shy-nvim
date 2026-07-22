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

  if not node then
    return
  end

  ---@diagnostic disable-next-line: undefined-field
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

  local path = node.absolute_path or vim.uv.cwd()
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
  ---@diagnostic disable-next-line: undefined-field
  if node.nodes ~= nil and node.parent == nil then
    return
  end

  api.node.open.edit()
end

-- 格式化字节数，优先复用 nvim-tree 的 format_bytes
local function format_size(bytes)
  local ok, utils = pcall(require, "nvim-tree.utils")
  if ok and utils.format_bytes then
    return utils.format_bytes(bytes)
  end
  -- 后备实现 (如果无法加载 utils)
  local units = { "B", "K", "M", "G", "T", "P", "E", "Z", "Y" }
  bytes = math.max(bytes, 0)
  local pow = math.floor((bytes > 0 and math.log(bytes) or 0) / math.log(1024))
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

-- 创建一个不抢焦点的浮动信息窗口，返回 { close, update } 句柄
local function open_info_popup(lines)
  local function width_of(ls)
    local w = 0
    for _, line in ipairs(ls) do
      w = math.max(w, vim.fn.strdisplaywidth(line))
    end
    return w
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "cursor",
    width = width_of(lines) + 1,
    height = #lines,
    col = 1,
    row = 1,
    style = "minimal",
    border = "rounded",
    noautocmd = true,
    zindex = 60,
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  -- 当在树 buffer 中移动光标或离开时自动关闭
  vim.api.nvim_create_autocmd("CursorMoved", { buffer = 0, callback = close, once = true })
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, { buffer = 0, callback = close, once = true })

  local function update(new_lines)
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_config(win, { width = width_of(new_lines) + 1, height = #new_lines })
    end
  end

  return { close = close, update = update }
end

-- 把 stat.mode 转成 rwxr-xr-x (644) 形式
local function format_mode(mode)
  local triads = "rwxrwxrwx"
  local out = {}
  for i = 1, 9 do
    local set = math.floor(mode / (2 ^ (9 - i))) % 2 == 1
    out[i] = set and triads:sub(i, i) or "-"
  end
  return table.concat(out) .. string.format(" (%03o)", mode % 512)
end

-- 收集节点的通用信息行 (路径/symlink/大小/权限/时间); size 由调用方传入,
-- extra 为可选的附加行 (如目录条目数), 紧跟在 size 之后显示
local function common_info_lines(path, stat, size_str, extra)
  local lines = { " fullpath: " .. path }

  -- 仅当节点自身是符号链接时显示指向目标
  local link = (vim.uv or vim.loop).fs_readlink(path)
  if link then
    table.insert(lines, " link:     → " .. link)
  end

  table.insert(lines, " size:     " .. size_str)
  if extra then
    table.insert(lines, extra)
  end

  if stat then
    table.insert(lines, " perms:    " .. format_mode(stat.mode))
    table.insert(lines, " accessed: " .. os.date("%x %X", stat.atime.sec))
    table.insert(lines, " modified: " .. os.date("%x %X", stat.mtime.sec))
    if stat.birthtime and stat.birthtime.sec and stat.birthtime.sec > 0 then
      table.insert(lines, " created:  " .. os.date("%x %X", stat.birthtime.sec))
    end
  end

  return lines
end

-- 统计目录的直接子项数 (libuv 单次 readdir, 同步且廉价); 返回 " items: ..." 行或 nil
local function dir_items_line(path)
  local uv = vim.uv or vim.loop
  local handle = uv.fs_scandir(path)
  if not handle then
    return nil
  end
  local files, dirs = 0, 0
  while true do
    local name, t = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if t == "directory" then
      dirs = dirs + 1
    else
      files = files + 1
    end
  end
  return string.format(" items:    %d 文件, %d 目录", files, dirs)
end

-- 目录信息：递归统计目录内所有文件大小的总和 (等价 du -As)
-- 注意: nvim-tree 内置的 show_info_popup 对目录显示的是 stat() 返回的目录 inode
-- 自身的元数据大小, 而非内容总和, 因此这里改用 du 异步计算真实总大小。
local function show_dir_info(node)
  local path = node.absolute_path
  local stat = node.fs_stat or (vim.uv or vim.loop).fs_stat(path)
  local items = dir_items_line(path)

  local popup = open_info_popup(common_info_lines(path, stat, "计算中…", items))

  -- 异步运行 du, 避免大目录阻塞 UI; -A 取 apparent size (各文件逻辑大小之和, 与 ls -l 一致)
  vim.system({ "du", "-A", "-s", "-k", path }, { text = true }, function(out)
    local size_str
    if out.code == 0 and out.stdout then
      local kb = out.stdout:match("^(%d+)")
      if kb then
        size_str = format_size(tonumber(kb) * 1024)
      end
    end
    size_str = size_str or "无法计算"
    vim.schedule(function()
      popup.update(common_info_lines(path, stat, size_str, items))
    end)
  end)
end

local IMAGE_EXTENSIONS = {
  png = true, jpg = true, jpeg = true, gif = true, webp = true, avif = true,
  svg = true, ico = true, bmp = true, pbm = true, pgm = true, ppm = true,
  tiff = true, tif = true,
}

-- 文件信息：立即显示基本信息, 若为图片再异步 (sips) 补充像素尺寸
local function show_file_info(node)
  local path = node.absolute_path
  local stat = node.fs_stat or (vim.uv or vim.loop).fs_stat(path)

  local ext = path:match("%.(%w+)$")
  ext = ext and ext:lower() or ""
  local is_image = IMAGE_EXTENSIONS[ext] or false

  local function build(dimensions)
    local lines = common_info_lines(path, stat, stat and format_size(stat.size) or "未知")
    if dimensions then
      table.insert(lines, " dimensions: " .. dimensions)
    end
    return lines
  end

  if not is_image then
    open_info_popup(build())
    return
  end

  -- 异步运行 sips, 避免大图阻塞 UI
  local popup = open_info_popup(build("读取中…"))
  vim.system({ "sips", "-g", "pixelWidth", "-g", "pixelHeight", path }, { text = true }, function(out)
    local dimensions
    if out.code == 0 and out.stdout then
      local w = out.stdout:match("pixelWidth:%s*(%d+)")
      local h = out.stdout:match("pixelHeight:%s*(%d+)")
      if w and h then
        dimensions = w .. "x" .. h
      end
    end
    vim.schedule(function()
      popup.update(build(dimensions or "未知"))
    end)
  end)
end

-- nvim-tree 按 i: 目录显示递归总大小, 文件显示基本信息 (图片附带尺寸)
local function get_node_info()
  local node = require("nvim-tree.api").tree.get_node_under_cursor()
  if not node then
    return
  end

  -- 跟随符号链接判断真实类型, 优先用已解析的 stat
  local stat = node.fs_stat or (vim.uv or vim.loop).fs_stat(node.absolute_path)
  if (stat and stat.type == "directory") or node.type == "directory" then
    show_dir_info(node)
  else
    show_file_info(node)
  end
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

  set("n", "i", get_node_info, opts("Node Info"))
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
  set("n", "f", api.filter.live.start, opts("Filter"))
  set("n", "F", api.filter.live.clear, opts("Clean Filter"))
  set("n", "B", api.filter.no_buffer.toggle, opts("Toggle Filter: No Buffer"))
  set("n", "C", api.filter.git.clean.toggle, opts("Toggle Filter: Git Clean"))
  set("n", "H", api.filter.dotfiles.toggle, opts("Toggle Filter: Dotfiles"))
  set("n", "I", api.filter.git.ignored.toggle, opts("Toggle Filter: Git Ignore"))
  set("n", "U", api.filter.custom.toggle, opts("Toggle Filter: Hidden"))

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
  init = function()
    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true

    require("config.directory_startup").open_nvim_tree_for_directory()
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
      highlight_diagnostics = false,
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
