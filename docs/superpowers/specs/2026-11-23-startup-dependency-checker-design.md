# 启动依赖检查器设计

## 背景与目标

本仓库是基于 LazyVim 的个人 Neovim 配置，依赖较多外部命令（Git、Node、C 编译器、ripgrep、lazygit、ranger/yazi、ImageMagick、Ghostscript、poppler 等）。新用户克隆配置后，往往缺少部分依赖，导致插件功能静默失效或启动时报错。

目标：在进入 Neovim 时静默检查全部依赖；若存在未忽略的缺失项，则弹出交互式浮动窗口，展示依赖状态与安装命令，并允许用户直接在终端分屏中执行安装。

## 目标与非目标

**目标**
- 全量检查 README 与代码中使用到的外部依赖（约 25 项）。
- 区分「必需」与「可选」依赖。
- 仅在存在未忽略的缺失项时弹窗；提供 `:ShyNvimCheckDeps` 手动查看全部。
- 支持包管理器自动检测（brew/apt/dnf/pacman/zypper/winget/scoop/choco/pipx/npm）。
- 安装前二次确认；安装过程在终端分屏运行，支持交互式输入（sudo 密码）。
- 可忽略可选依赖，并持久化忽略状态。
- 不破坏现有 `scripts/check.sh` 与测试。

**非目标**
- 不自动安装 Neovim 本体、字体、终端模拟器等无法通过包管理器统一处理的项。
- 不替代 `:checkhealth`，不检查 Lua 插件或 LSP 服务器。
- 不做跨平台包管理器的完整等价映射；未知包管理器时仅展示安装提示与命令。
- 不在 headless/无 UI 环境中弹窗。

## 现有基础

- `lua/util/external_commands.lua` 已提供 `executable()` 与命令检测能力。
- `README.md` 已列出完整前置依赖与安装提示。
- `lua/plugins/*.lua` 中有 `vim.fn.executable` 检查（Floaterm、csvview、nvim-tree）。
- LazyVim 会在 VeryLazy 阶段自动加载 `lua/config/autocmds.lua`。

## 方案对比与选择

- **方式 A（采用）**：自定义 Lua 依赖管理器 + 浮动窗口 + 终端安装。完全可控，可交互，符合“插件安装机制”体验。
- **方式 B**：复用 snacks.nvim 窗口/选择器。UI 更统一，但安装执行仍需自写，且增加加载时序复杂度。
- **方式 C**：只读检查 + 复制命令。最简单，但不满足交互安装需求。

选择方式 A。

## 设计

### 模块拆分

- `lua/util/dependencies.lua`：依赖注册表、检查逻辑、包管理器检测、状态持久化、UI 控制器。
- `lua/config/autocmds.lua`：注册 `VimEnter` 静默检查（仅 UI 环境）。
- 用户命令：`:ShyNvimCheckDeps`、`:ShyNvimCheckDepsRefresh`。

### 依赖注册表

每项依赖结构：

```lua
{
  id = "rg",
  name = "ripgrep",
  commands = { "rg" },          -- 任一命令存在即视为已安装
  required = false,
  category = "搜索",
  note = "fzf-lua 文本搜索",
  version = {                  -- 可选
    cmd = "rg",
    args = { "--version" },
    min = "13.0.0",
  },
  install = {
    brew = "brew install ripgrep",
    apt = "sudo apt-get install -y ripgrep",
    dnf = "sudo dnf install -y ripgrep",
    pacman = "sudo pacman -S --noconfirm ripgrep",
    winget = "winget install BurntSushi.ripgrep.MSVC",
    scoop = "scoop install ripgrep",
    choco = "choco install ripgrep",
  },
  hint = "https://github.com/BurntSushi/ripgrep",
}
```

特殊依赖：
- C 编译器：`commands = { "cc", "gcc", "clang" }`，任一存在即可。
- 图片尺寸：`commands = { "sips", "identify" }`，任一存在即可。
- Neovim：检查当前运行版本 `vim.version()`，要求 ≥0.11.2。

### 包管理器检测

优先级：
1. macOS：`brew`
2. Windows：`winget` → `scoop` → `choco`
3. Linux：`apt-get` → `dnf` → `pacman` → `zypper`
4. 语言工具：`pipx`、`npm`（用于 xlsx2csv 等）

若未检测到包管理器，UI 仍显示依赖与 `hint`，但禁用安装动作并提示手动安装。

### 检查流程

1. `M.check()` 遍历注册表，返回结果列表：`{ dep, installed, version, missing }`。
2. 过滤已忽略的可选依赖（根据持久化状态）。
3. `M.maybe_open()`：若存在缺失项，则打开 UI；否则静默返回。
4. `VimEnter` 中 `vim.schedule(M.maybe_open)`，并限制在 UI 环境（`#vim.api.nvim_list_uis() > 0`）。

### UI 设计

浮动窗口（`nvim_open_win`），标题 `依赖检查`，内容按类别分组：

```
依赖检查（缺失 4 项）  包管理器: Homebrew

[必需] Git 2.45.0                 ✓
[必需] C 编译器                   ✗  brew install gcc
[可选] ripgrep                    ✗  brew install ripgrep
...

快捷键: <CR> 安装选中项 | i 忽略可选项 | r 重新检查 | q 关闭
```

- 状态使用 extmark 高亮：绿色 `✓`、红色 `✗`、黄色 `!`（版本过低）。
- 每行记录对应的依赖索引，支持光标定位。
- `<CR>`：对当前缺失依赖执行安装（先 `vim.fn.confirm` 确认）。
- `i`：切换当前可选依赖的忽略状态并持久化。
- `r`：重新检查并刷新 UI。
- `q`/`<Esc>`：关闭窗口。

### 安装执行

- 解析当前依赖的安装命令（基于检测到的包管理器）。
- 若命令存在：`vim.fn.confirm` 确认后，打开底部 12 行终端分屏执行命令（`termopen`），允许交互。
- 若命令不存在：通知用户并显示 `hint`。
- 安装完成后不自动关闭终端；用户可按 `q` 关闭依赖窗口，终端仍保留供查看。

### 状态持久化

路径：`vim.fn.stdpath("state") .. "/shy-nvim/deps.json"`

结构：

```json
{
  "ignored": { "rg": true, "fd": true },
  "package_manager": "brew"
}
```

- 仅持久化忽略列表与包管理器偏好。
- 首次启动时若文件不存在则创建空状态。

### 用户命令

- `:ShyNvimCheckDeps`：强制打开 UI（显示全部依赖，含已忽略项标记）。
- `:ShyNvimCheckDepsRefresh`：重新检查并刷新当前 UI；无 UI 时等同打开。

### 测试与兼容性

- 新增 `tests/dependencies_spec.lua`：测试注册表结构、检查函数、包管理器检测、状态读写（使用临时目录）。
- `scripts/check.sh` 的 Lua 语法检查会覆盖新文件。
- 守卫：headless 环境（`#vim.api.nvim_list_uis() == 0`）不弹窗；测试环境可通过 `vim.g.shy_nvim_disable_deps_check = true` 禁用。
- 不在 `minimal_init.lua` 路径中触发弹窗，避免影响现有测试。

## 待确认

- 安装命令矩阵是否需要覆盖你常用的包管理器（当前包含 brew/apt/dnf/pacman/zypper/winget/scoop/choco/pipx/npm）。
- 是否需要为数据库客户端（mysql/psql/sqlite3）增加单独检查项。

---

请确认以上设计；确认后我将按 `writing-plans` 生成实现计划并开始编码。