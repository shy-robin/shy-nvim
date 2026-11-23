local M = {}

-- ---------------------------------------------------------------------------
-- 版本比较
-- ---------------------------------------------------------------------------

function M.version_compare(a, b)
  a = tostring(a or "")
  b = tostring(b or "")
  local function parts(v)
    local out = {}
    for n in v:gmatch("%d+") do
      table.insert(out, tonumber(n))
    end
    return out
  end
  local pa, pb = parts(a), parts(b)
  local n = math.max(#pa, #pb)
  for i = 1, n do
    local x = pa[i] or 0
    local y = pb[i] or 0
    if x ~= y then
      return x < y and -1 or 1
    end
  end
  return 0
end

-- ---------------------------------------------------------------------------
-- 依赖注册表
-- ---------------------------------------------------------------------------

M.registry = {
  -- 必需
  {
    id = "nvim",
    name = "Neovim",
    commands = { "nvim" },
    required = true,
    category = "核心",
    note = ">= 0.11.2，LuaJIT 构建",
    version = { min = "0.11.2" },
    install = {},
    hint = "https://neovim.io/",
  },
  {
    id = "git",
    name = "Git",
    commands = { "git" },
    required = true,
    category = "核心",
    note = ">= 2.19.0，部分克隆支持",
    version = { min = "2.19.0", command = "git", args = { "--version" } },
    install = {
      brew = "brew install git",
      apt = "sudo apt-get install -y git",
      dnf = "sudo dnf install -y git",
      pacman = "sudo pacman -S --noconfirm git",
      zypper = "sudo zypper install -y git",
      winget = "winget install Git.Git",
      scoop = "scoop install git",
      choco = "choco install git",
    },
    hint = "https://git-scm.com/",
  },
  {
    id = "cc",
    name = "C 编译器",
    commands = { "cc", "gcc", "clang" },
    any = true,
    required = true,
    category = "核心",
    note = "nvim-treesitter 编译 parser",
    install = {
      brew = "brew install gcc",
      apt = "sudo apt-get install -y build-essential",
      dnf = "sudo dnf groupinstall -y 'Development Tools'",
      pacman = "sudo pacman -S --noconfirm base-devel",
      zypper = "sudo zypper install -y gcc make",
      winget = "winget install GnuWin32.Make", -- 兜底提示
      choco = "choco install mingw",
    },
    hint = "https://github.com/nvim-treesitter/nvim-treesitter#requirements",
  },
  {
    id = "curl",
    name = "curl",
    commands = { "curl" },
    required = true,
    category = "LSP/Markdown",
    note = "blink.cmp 必需",
    install = {
      brew = "brew install curl",
      apt = "sudo apt-get install -y curl",
      dnf = "sudo dnf install -y curl",
      pacman = "sudo pacman -S --noconfirm curl",
      zypper = "sudo zypper install -y curl",
      winget = "winget install cURL.cURL",
      scoop = "scoop install curl",
      choco = "choco install curl",
    },
    hint = "https://curl.se/",
  },
  {
    id = "node",
    name = "Node.js",
    commands = { "node" },
    required = true,
    category = "LSP/Markdown",
    note = ">= 16.18.0，部分 LSP 与 Markdown Preview",
    version = { min = "16.18.0", command = "node", args = { "--version" } },
    install = {
      brew = "brew install node",
      apt = "sudo apt-get install -y nodejs npm",
      dnf = "sudo dnf install -y nodejs npm",
      pacman = "sudo pacman -S --noconfirm nodejs npm",
      zypper = "sudo zypper install -y nodejs npm",
      winget = "winget install OpenJS.NodeJS",
      scoop = "scoop install nodejs",
      choco = "choco install nodejs",
    },
    hint = "https://nodejs.org/",
  },
  {
    id = "npm",
    name = "npm",
    commands = { "npm" },
    required = true,
    category = "LSP/Markdown",
    note = "Markdown Preview 构建",
    install = {
      brew = "brew install npm",
      apt = "sudo apt-get install -y npm",
      dnf = "sudo dnf install -y npm",
      pacman = "sudo pacman -S --noconfirm npm",
      zypper = "sudo zypper install -y npm",
      winget = "winget install OpenJS.NodeJS",
      scoop = "scoop install nodejs",
      choco = "choco install nodejs",
    },
    hint = "https://nodejs.org/",
  },
  {
    id = "npx",
    name = "npx",
    commands = { "npx" },
    required = true,
    category = "LSP/Markdown",
    note = "Markdown Preview 构建",
    install = {
      brew = "brew install npm",
      apt = "sudo apt-get install -y npm",
      dnf = "sudo dnf install -y npm",
      pacman = "sudo pacman -S --noconfirm npm",
      zypper = "sudo zypper install -y npm",
      winget = "winget install OpenJS.NodeJS",
      scoop = "scoop install nodejs",
      choco = "choco install nodejs",
    },
    hint = "https://nodejs.org/",
  },
  {
    id = "sh",
    name = "sh",
    commands = { "sh" },
    required = true,
    category = "LSP/Markdown",
    note = "Markdown Preview 构建",
    install = {},
    hint = "系统自带",
  },
  -- 可选
  {
    id = "rg",
    name = "ripgrep",
    commands = { "rg" },
    required = false,
    category = "搜索",
    note = "fzf-lua 文本搜索",
    install = {
      brew = "brew install ripgrep",
      apt = "sudo apt-get install -y ripgrep",
      dnf = "sudo dnf install -y ripgrep",
      pacman = "sudo pacman -S --noconfirm ripgrep",
      zypper = "sudo zypper install -y ripgrep",
      winget = "winget install BurntSushi.ripgrep.MSVC",
      scoop = "scoop install ripgrep",
      choco = "choco install ripgrep",
    },
    hint = "https://github.com/BurntSushi/ripgrep",
  },
  {
    id = "fd",
    name = "fd",
    commands = { "fd", "fdfind" },
    any = true,
    required = false,
    category = "搜索",
    note = "fzf-lua 文件搜索",
    install = {
      brew = "brew install fd",
      apt = "sudo apt-get install -y fd-find",
      dnf = "sudo dnf install -y fd-find",
      pacman = "sudo pacman -S --noconfirm fd",
      zypper = "sudo zypper install -y fd",
      winget = "winget install sharkdp.fd",
      scoop = "scoop install fd",
      choco = "choco install fd",
    },
    hint = "https://github.com/sharkdp/fd",
  },
  {
    id = "fzf",
    name = "fzf",
    commands = { "fzf" },
    required = false,
    category = "搜索",
    note = "fzf-lua 选择器",
    install = {
      brew = "brew install fzf",
      apt = "sudo apt-get install -y fzf",
      dnf = "sudo dnf install -y fzf",
      pacman = "sudo pacman -S --noconfirm fzf",
      zypper = "sudo zypper install -y fzf",
      winget = "winget install junegunn.fzf",
      scoop = "scoop install fzf",
      choco = "choco install fzf",
    },
    hint = "https://github.com/junegunn/fzf",
  },
  {
    id = "lazygit",
    name = "lazygit",
    commands = { "lazygit" },
    required = false,
    category = "Git",
    note = "Git TUI",
    install = {
      brew = "brew install lazygit",
      apt = "sudo apt-get install -y lazygit",
      dnf = "sudo dnf install -y lazygit",
      pacman = "sudo pacman -S --noconfirm lazygit",
      winget = "winget install JesseDuffield.lazygit",
      scoop = "scoop install lazygit",
      choco = "choco install lazygit",
    },
    hint = "https://github.com/jesseduffield/lazygit",
  },
  {
    id = "ranger",
    name = "ranger",
    commands = { "ranger" },
    required = false,
    category = "Floaterm",
    note = "<leader>tor",
    install = {
      brew = "brew install ranger",
      apt = "sudo apt-get install -y ranger",
      dnf = "sudo dnf install -y ranger",
      pacman = "sudo pacman -S --noconfirm ranger",
      pipx = "pipx install ranger-fm",
    },
    hint = "https://github.com/ranger/ranger",
  },
  {
    id = "yazi",
    name = "yazi",
    commands = { "yazi" },
    required = false,
    category = "Floaterm",
    note = "<leader>y",
    install = {
      brew = "brew install yazi",
      cargo = "cargo install --locked yazi-fm",
    },
    hint = "https://github.com/sxyazi/yazi",
  },
  {
    id = "python3",
    name = "Python 3",
    commands = { "python3", "python" },
    any = true,
    required = false,
    category = "Floaterm",
    note = "终端与 xlsx2csv",
    install = {
      brew = "brew install python",
      apt = "sudo apt-get install -y python3",
      dnf = "sudo dnf install -y python3",
      pacman = "sudo pacman -S --noconfirm python",
      winget = "winget install Python.Python.3",
      scoop = "scoop install python",
      choco = "choco install python",
    },
    hint = "https://www.python.org/",
  },
  {
    id = "xlsx2csv",
    name = "xlsx2csv",
    commands = { "xlsx2csv" },
    required = false,
    category = "CSV",
    note = "xlsx 预览",
    install = {
      pipx = "pipx install xlsx2csv",
      brew = "brew install xlsx2csv",
    },
    hint = "pipx install xlsx2csv",
  },
  {
    id = "image_tool",
    name = "图片尺寸工具",
    commands = { "sips", "identify" },
    any = true,
    required = false,
    category = "nvim-tree",
    note = "macOS sips 或 ImageMagick identify",
    install = {
      brew = "brew install imagemagick",
      apt = "sudo apt-get install -y imagemagick",
      dnf = "sudo dnf install -y ImageMagick",
      pacman = "sudo pacman -S --noconfirm imagemagick",
      winget = "winget install ImageMagick.ImageMagick",
      scoop = "scoop install imagemagick",
      choco = "choco install imagemagick",
    },
    hint = "macOS 自带 sips",
  },
  {
    id = "magick",
    name = "ImageMagick (magick)",
    commands = { "magick" },
    required = false,
    category = "PDF",
    note = "pdfreader.nvim",
    install = {
      brew = "brew install imagemagick",
      apt = "sudo apt-get install -y imagemagick",
      dnf = "sudo dnf install -y ImageMagick",
      pacman = "sudo pacman -S --noconfirm imagemagick",
      winget = "winget install ImageMagick.ImageMagick",
      scoop = "scoop install imagemagick",
      choco = "choco install imagemagick",
    },
    hint = "https://imagemagick.org/",
  },
  {
    id = "gs",
    name = "Ghostscript",
    commands = { "gs" },
    required = false,
    category = "PDF",
    note = "pdfreader.nvim",
    install = {
      brew = "brew install ghostscript",
      apt = "sudo apt-get install -y ghostscript",
      dnf = "sudo dnf install -y ghostscript",
      pacman = "sudo pacman -S --noconfirm ghostscript",
      winget = "winget install ArtifexSoftware.Ghostscript",
      scoop = "scoop install ghostscript",
      choco = "choco install ghostscript",
    },
    hint = "https://www.ghostscript.com/",
  },
  {
    id = "pdftotext",
    name = "pdftotext",
    commands = { "pdftotext" },
    required = false,
    category = "PDF",
    note = "poppler，pdfreader.nvim",
    install = {
      brew = "brew install poppler",
      apt = "sudo apt-get install -y poppler-utils",
      dnf = "sudo dnf install -y poppler-utils",
      pacman = "sudo pacman -S --noconfirm poppler",
      winget = "winget install oschwartz10612.Poppler",
      scoop = "scoop install poppler",
      choco = "choco install poppler",
    },
    hint = "https://poppler.freedesktop.org/",
  },
  {
    id = "pdfinfo",
    name = "pdfinfo",
    commands = { "pdfinfo" },
    required = false,
    category = "PDF",
    note = "poppler，pdfreader.nvim",
    install = {
      brew = "brew install poppler",
      apt = "sudo apt-get install -y poppler-utils",
      dnf = "sudo dnf install -y poppler-utils",
      pacman = "sudo pacman -S --noconfirm poppler",
      winget = "winget install oschwartz10612.Poppler",
      scoop = "scoop install poppler",
      choco = "choco install poppler",
    },
    hint = "https://poppler.freedesktop.org/",
  },
  {
    id = "db_client",
    name = "数据库客户端",
    commands = { "mysql", "psql", "sqlite3" },
    any = true,
    required = false,
    category = "数据库",
    note = "vim-dadbod，任一即可",
    install = {
      brew = "brew install mysql postgresql sqlite",
      apt = "sudo apt-get install -y mysql-client postgresql-client sqlite3",
      dnf = "sudo dnf install -y mysql postgresql sqlite",
      pacman = "sudo pacman -S --noconfirm mysql postgresql sqlite",
    },
    hint = "按需安装 mysql/psql/sqlite3",
  },
}

-- ---------------------------------------------------------------------------
-- 包管理器检测
-- ---------------------------------------------------------------------------

local function is_mac()
  return vim.fn.has("mac") == 1
end

local function is_win()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

function M.detect_package_manager()
  if is_mac() then
    if vim.fn.executable("brew") == 1 then
      return "brew"
    end
  elseif is_win() then
    for _, pm in ipairs({ "winget", "scoop", "choco" }) do
      if vim.fn.executable(pm) == 1 then
        return pm
      end
    end
  else
    for _, pm in ipairs({ "apt-get", "dnf", "pacman", "zypper" }) do
      if vim.fn.executable(pm) == 1 then
        -- normalize apt-get -> apt? keep apt-get key? registry uses apt
        if pm == "apt-get" then
          return "apt"
        end
        return pm
      end
    end
  end
  if vim.fn.executable("pipx") == 1 then
    return "pipx"
  end
  if vim.fn.executable("npm") == 1 then
    return "npm"
  end
  return nil
end

function M.install_command(dep, pm)
  pm = pm or M.detect_package_manager()
  if dep.install and pm and dep.install[pm] then
    return dep.install[pm]
  end
  -- 兜底：pipx 优先用于 python 工具
  if dep.install and dep.install.pipx and vim.fn.executable("pipx") == 1 then
    return dep.install.pipx
  end
  if dep.install and dep.install.default then
    return dep.install.default
  end
  return nil
end

-- ---------------------------------------------------------------------------
-- 版本检查
-- ---------------------------------------------------------------------------

local function installed_commands(dep)
  if dep.any then
    for _, cmd in ipairs(dep.commands) do
      if vim.fn.executable(cmd) == 1 then
        return true, cmd
      end
    end
    return false, nil
  end
  for _, cmd in ipairs(dep.commands) do
    if vim.fn.executable(cmd) ~= 1 then
      return false, nil
    end
  end
  return true, dep.commands[1]
end

local function check_version(dep, cmd)
  -- Neovim 特殊处理：直接使用运行时版本
  if dep.id == "nvim" then
    local v = vim.version()
    local current = string.format("%d.%d.%d", v.major, v.minor, v.patch)
    local min = (dep.version and dep.version.min) or "0.11.2"
    return M.version_compare(current, min) >= 0, current
  end
  if not dep.version or not dep.version.min then
    return true, nil
  end
  local command = dep.version.command or cmd
  local args = dep.version.args or { "--version" }
  local full = { command }
  for _, a in ipairs(args) do
    table.insert(full, a)
  end
  local ok, output = pcall(vim.fn.system, full)
  if not ok or vim.v.shell_error ~= 0 then
    return true, nil
  end
  local version = tostring(output):match("%d+%.%d+%.?%d*")
  if not version then
    return true, nil
  end
  return M.version_compare(version, dep.version.min) >= 0, version
end

function M.check_one(dep)
  local installed, cmd = installed_commands(dep)
  local version_ok, version = true, nil
  if installed then
    version_ok, version = check_version(dep, cmd)
  end
  return {
    dep = dep,
    installed = installed,
    version = version,
    version_ok = version_ok,
    missing = not (installed and version_ok),
  }
end

function M.check_all(include_ignored)
  include_ignored = include_ignored == true
  local results = {}
  for _, dep in ipairs(M.registry) do
    local ignored = (dep.required == false and M.is_ignored(dep.id))
    if include_ignored or not ignored then
      local r = M.check_one(dep)
      r.ignored = ignored
      table.insert(results, r)
    end
  end
  return results
end

-- ---------------------------------------------------------------------------
-- 状态持久化
-- ---------------------------------------------------------------------------

function M.state_path()
  if vim.env.SHY_NVIM_DEPS_STATE and vim.env.SHY_NVIM_DEPS_STATE ~= "" then
    return vim.env.SHY_NVIM_DEPS_STATE
  end
  if vim.g.shy_nvim_deps_state_path then
    return vim.g.shy_nvim_deps_state_path
  end
  return vim.fn.stdpath("state") .. "/shy-nvim/deps.json"
end

function M.load_state()
  local path = M.state_path()
  local f = io.open(path, "r")
  if not f then
    return { ignored = {}, package_manager = nil }
  end
  local content = f:read("*a")
  f:close()
  local ok, decoded = pcall(vim.json.decode, content)
  if not ok or type(decoded) ~= "table" then
    return { ignored = {}, package_manager = nil }
  end
  decoded.ignored = decoded.ignored or {}
  return decoded
end

function M.save_state(state)
  state = state or M.load_state()
  state.ignored = state.ignored or {}
  local path = M.state_path()
  local dir = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(dir, "p")
  local f = io.open(path, "w")
  if not f then
    return false
  end
  f:write(vim.json.encode(state))
  f:close()
  return true
end

function M.is_ignored(id)
  local state = M.load_state()
  return state.ignored[id] == true
end

function M.set_ignored(id, value)
  local state = M.load_state()
  state.ignored = state.ignored or {}
  if value then
    state.ignored[id] = true
  else
    state.ignored[id] = nil
  end
  M.save_state(state)
end

-- ---------------------------------------------------------------------------
-- UI
-- ---------------------------------------------------------------------------

local ui = {
  buf = nil,
  win = nil,
  results = {},
  line_map = {},
  show_ignored = false,
}

local function close_ui()
  if ui.win and vim.api.nvim_win_is_valid(ui.win) then
    vim.api.nvim_win_close(ui.win, true)
  end
  if ui.buf and vim.api.nvim_buf_is_valid(ui.buf) then
    vim.api.nvim_buf_delete(ui.buf, { force = true })
  end
  ui.win = nil
  ui.buf = nil
end

M.close = close_ui

local function status_symbol(r)
  if r.ignored then
    return "·"
  end
  if not r.installed then
    return "✗"
  end
  if not r.version_ok then
    return "!"
  end
  return "✓"
end

local function status_hl(r)
  if r.ignored then
    return "ShyDepsIgnored"
  end
  if not r.installed then
    return "ShyDepsMissing"
  end
  if not r.version_ok then
    return "ShyDepsWarn"
  end
  return "ShyDepsOk"
end

local function render()
  if not ui.buf or not vim.api.nvim_buf_is_valid(ui.buf) then
    return
  end
  local pm = M.detect_package_manager()
  local missing_count = 0
  for _, r in ipairs(ui.results) do
    if r.missing and not r.ignored then
      missing_count = missing_count + 1
    end
  end

  local lines = {}
  table.insert(
    lines,
    string.format("缺失 %d/%d 项依赖    包管理器: %s", missing_count, #ui.results, pm or "未检测到")
  )
  table.insert(lines, "")
  ui.line_map = {}

  -- 按类别分组
  local categories = {}
  local category_order = {}
  for _, r in ipairs(ui.results) do
    if not categories[r.dep.category] then
      categories[r.dep.category] = {}
      table.insert(category_order, r.dep.category)
    end
    table.insert(categories[r.dep.category], r)
  end

  for _, cat in ipairs(category_order) do
    table.insert(lines, "  " .. cat)
    for _, r in ipairs(categories[cat]) do
      local idx
      for i, rr in ipairs(ui.results) do
        if rr == r then
          idx = i
          break
        end
      end
      local req = r.dep.required and "必需" or "可选"
      local extra = ""
      if r.ignored then
        extra = "已忽略（按 i 取消）"
      elseif r.missing then
        local c = M.install_command(r.dep, pm)
        extra = c or (r.dep.hint or "")
      else
        extra = r.version or "已安装"
      end
      -- 计算名称列对齐宽度
      local max_name = 0
      for _, rr in ipairs(ui.results) do
        max_name = math.max(max_name, vim.fn.strdisplaywidth(rr.dep.name))
      end
      max_name = math.max(max_name, 8)
      local padded_name = r.dep.name .. string.rep(" ", max_name - vim.fn.strdisplaywidth(r.dep.name))
      local line = "  " .. status_symbol(r) .. "  " .. req .. "  " .. padded_name .. "  " .. extra
      table.insert(lines, line)
      ui.line_map[#lines] = idx
    end
    table.insert(lines, "")
  end

  vim.api.nvim_buf_set_option(ui.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(ui.buf, "modifiable", false)

  -- extmarks
  local ns = vim.api.nvim_create_namespace("shy_deps")
  vim.api.nvim_buf_clear_namespace(ui.buf, ns, 0, -1)
  for lnum, idx in pairs(ui.line_map) do
    local r = ui.results[idx]
    local symbol = status_symbol(r)
    local pos = lines[lnum]:find(symbol, 1, true)
    if pos then
      vim.api.nvim_buf_set_extmark(ui.buf, ns, lnum - 1, pos - 1, {
        end_col = pos - 1 + #symbol,
        hl_group = status_hl(r),
      })
    end
  end
end

local function setup_highlights()
  vim.api.nvim_set_hl(0, "ShyDepsOk", { link = "DiagnosticOk", default = true })
  vim.api.nvim_set_hl(0, "ShyDepsMissing", { link = "DiagnosticError", default = true })
  vim.api.nvim_set_hl(0, "ShyDepsWarn", { link = "DiagnosticWarn", default = true })
  vim.api.nvim_set_hl(0, "ShyDepsIgnored", { link = "Comment", default = true })
end

local function open_ui(force)
  setup_highlights()
  ui.show_ignored = (force == true)
  if ui.win and vim.api.nvim_win_is_valid(ui.win) then
    -- already open; refresh
    M.refresh()
    return
  end
  ui.results = M.check_all(ui.show_ignored)
  if not force then
    local has_missing = false
    for _, r in ipairs(ui.results) do
      if r.missing then
        has_missing = true
        break
      end
    end
    if not has_missing then
      vim.notify("所有依赖已安装", vim.log.levels.INFO)
      return
    end
  end

  ui.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui.buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(ui.buf, "filetype", "shydeps")

  local width = math.min(100, vim.o.columns - 4)
  local height = math.min(30, vim.o.lines - 4)
  ui.win = vim.api.nvim_open_win(ui.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " 依赖检查 ",
    title_pos = "center",
    footer = " <CR> 安装  i 忽略  r 刷新  q 关闭 ",
    footer_pos = "center",
  })

  -- keymaps
  local opts = { buffer = ui.buf, nowait = true, silent = true }
  vim.keymap.set("n", "q", close_ui, opts)
  vim.keymap.set("n", "<Esc>", close_ui, opts)
  vim.keymap.set("n", "r", function()
    M.refresh()
  end, opts)
  vim.keymap.set("n", "i", function()
    local lnum = vim.api.nvim_win_get_cursor(ui.win)[1]
    local idx = ui.line_map[lnum]
    if not idx then
      return
    end
    local r = ui.results[idx]
    if r.dep.required then
      vim.notify("必需依赖不能忽略", vim.log.levels.WARN)
      return
    end
    local new_state = not M.is_ignored(r.dep.id)
    M.set_ignored(r.dep.id, new_state)
    M.refresh()
  end, opts)
  vim.keymap.set("n", "<CR>", function()
    local lnum = vim.api.nvim_win_get_cursor(ui.win)[1]
    local idx = ui.line_map[lnum]
    if not idx then
      return
    end
    local r = ui.results[idx]
    if not r.missing then
      vim.notify(r.dep.name .. " 已安装", vim.log.levels.INFO)
      return
    end
    local pm = M.detect_package_manager()
    local cmd = M.install_command(r.dep, pm)
    if not cmd then
      vim.notify(r.dep.name .. " 无自动安装命令，请手动安装: " .. (r.dep.hint or ""), vim.log.levels.WARN)
      return
    end
    if vim.fn.confirm("执行安装命令?\n" .. cmd, "&Yes\n&No", 2) ~= 1 then
      return
    end
    close_ui()
    vim.cmd("botright 12new")
    vim.fn.termopen(cmd)
    vim.cmd("startinsert")
  end, opts)

  render()
end

M.open = open_ui

function M.refresh()
  if not ui.buf or not vim.api.nvim_buf_is_valid(ui.buf) then
    M.open(true)
    return
  end
  ui.results = M.check_all(ui.show_ignored)
  render()
end

function M.maybe_open()
  if vim.g.shy_nvim_disable_deps_check then
    return
  end
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  local results = M.check_all()
  local has_missing = false
  for _, r in ipairs(results) do
    if r.missing then
      has_missing = true
      break
    end
  end
  if has_missing then
    open_ui(false)
  end
end

function M.setup()
  if vim.g.shy_nvim_deps_setup_done then
    return
  end
  vim.g.shy_nvim_deps_setup_done = true
  vim.api.nvim_create_user_command("ShyNvimCheckDeps", function()
    M.open(true)
  end, {})
  vim.api.nvim_create_user_command("ShyNvimCheckDepsRefresh", function()
    M.refresh()
  end, {})
end

return M
