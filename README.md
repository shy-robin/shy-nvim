<h1 align="center">ShyNvim</h1>

<p align="center">
这是我个人维护的一套 Neovim 配置（基于  <a href="https://github.com/LazyVim">💤 LazyNvim</a>），配置简单灵活，预设一套 <b>Web 前端</b> 的开发环境。
</p>

## 🌟 预览

![Preview Image](https://s2.loli.net/2024/12/05/sUzNPo2hX8CyeR7.png)

## ✨ 功能

- 包管理器 [lazy.nvim](https://github.com/folke/lazy.nvim)
- 文件浏览器 [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)
- 代码补全、格式化、语法检查 [coc.nvim](https://github.com/neoclide/coc.nvim)
- 语法高亮 [treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Git 集成 [gitsigns](https://github.com/lewis6991/gitsigns.nvim) [lazygit](https://github.com/jesseduffield/lazygit)
- 状态栏 [bufferline](https://github.com/akinsho/bufferline.nvim) [lualine](https://github.com/nvim-lualine/lualine.nvim)
- 浮动终端 [vim-floaterm](https://github.com/voldikss/vim-floaterm)
- 模糊搜索 [telescope](https://github.com/nvim-telescope/telescope.nvim)
- 代码调试 [nvim-dap](https://github.com/mfussenegger/nvim-dap)

## ⚡️ 前置条件

- [LazyVim](https://www.lazyvim.org/) 前置依赖（具体参考：[LazyVim Requirements](https://www.lazyvim.org/#%EF%B8%8F-requirements)）
  - [neovim](https://neovim.io/) >= **0.9.0** （需要用 **LuaJIT** 构建）
  - [git](https://git-scm.com/) >= **2.19.0** （用于部分克隆支持）
  - 一个 [Nerd Font](https://www.nerdfonts.com/) 字体 **_（可选）_**
  - [lazygit](https://github.com/jesseduffield/lazygit) **_（可选）_**
  - 一个用于 `nvim-treesitter` 的 **C** 编译器。看 [这里](https://github.com/nvim-treesitter/nvim-treesitter#requirements)
  - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 依赖 **_（可选）_**
    - [ripgrep](https://github.com/BurntSushi/ripgrep)（搜索字符 ）
    - [fd](https://github.com/sharkdp/fd)（搜索文件 ）
  - 终端（支持展示颜色和下划线样式的终端）
    - [kitty](https://github.com/kovidgoyal/kitty) (Linux & Macos)
    - [wezterm](https://github.com/wez/wezterm) (Linux, Macos & Windows)
    - [alacritty](https://github.com/alacritty/alacritty) (Linux, Macos & Windows)
    - [iterm2](https://iterm2.com/) (Macos)
- [coc.nvim](https://github.com/neoclide/coc.nvim) 前置依赖
  - [nodejs](https://nodejs.org/en/download/) >= 16.18.0
  - [watchman](https://facebook.github.io/watchman/)（volar 服务会用到，具体参考：[[RECOMMENDED] Additional installation of "watchman"](https://github.com/yaegassy/coc-volar?tab=readme-ov-file#recommended-additional-installation-of-watchman)）
- [ultisnips](https://github.com/SirVer/ultisnips) 前置依赖
  - ultisnips 需要依赖 python，因此需要提前安装 python，否则无法正常使用代码片段
    1. 安装 python：`brew install python`，检查是否安装成功：`python3 --version`
    2. 安装 pynvim：`pip3 install pynvim`，如果安装提示 ssl 的报错，需要断开 vpn 进行安装，检查是否安装成功：`python3` -> `import pynvim` -> `print(pynvim.__vesion__)`
    3. 检查 nvim 是否安装 python 环境：`:echo has('python3')`，若返回 1 则有，若为 0 则无
- 其他依赖
  - `:checkhealth snacks`
  * `:checkhealth img-clip`

## 🚀 开始使用

1. 备份你的原有配置

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

2. 克隆我的配置

```shell
git clone --depth 1 https://github.com/shy-robin/shy-nvim ~/.config/nvim
```

3. 删除 `.git` 文件夹，以便稍后将其添加到您自己的仓库

```shell
rm -rf ~/.config/nvim/.git
```

4. 启动 Neovim!

```shell
nvim
```

## 📄 功能指南

### 搜索文件

| 功能                 | 快捷键                                                                                   | 描述                                                           |
| -------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| 搜索文件（Root Dir） | <kbd>leader</kbd> + <kbd>leader</kbd> 或 <kbd>leader</kbd> + <kbd>f</kbd> + <kbd>f</kbd> | 搜索当前 buffer 根目录下的文件（不包含 ignore 和 hidden 文件） |
| 搜索文件（cwd）      | <kbd>leader</kbd> + <kbd>f</kbd> + <kbd>F</kbd>                                          | 搜索当前工作目录下的文件（不包含 ignore 和 hidden 文件）       |
| 搜索隐藏文件         | 搜索框下按 <kbd>Ctrl</kbd> + <kbd>u</kbd>                                                | 搜索 hidden 文件（比如 `.git` 等）                             |
| 搜索 git 忽略文件    | 搜索框下按 <kbd>Ctrl</kbd> + <kbd>i</kbd>                                                | 搜索 ignore 文件（比如 `.gitignore` 里的文件等）               |

> Root Dir 是指当前 buffer 的根目录，cwd 是指当前工作目录。
> 比如，在 `~/.config/nvim/` 打开 nvim 时，cwd 为 `~/.config/nvim/`，Root Dir 为 `~/.config/nvim`，如果在项目内打开 `~/Projects/demo/index.js` 文件，
> cwd 为 `~/.config/nvim/`，Root Dir 为 `~/Projects/demo/`。

### 搜索文本

| 功能                 | 快捷键                                                                              | 描述                                                                  |
| -------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| 搜索文本（Root Dir） | <kbd>leader</kbd> + <kbd>/</kbd> 或 <kbd>leader</kbd> + <kbd>s</kbd> + <kbd>g</kbd> | 搜索当前 buffer 根目录下的文本（不包含 ignore 和 hidden 文件）        |
| 搜索文本（cwd）      | <kbd>leader</kbd> + <kbd>s</kbd> + <kbd>G</kbd>                                     | 搜索当前工作目录下的文本（不包含 ignore 和 hidden 文件）              |
| 搜索 git 忽略文本    | 搜索框下按 <kbd>Ctrl</kbd> + <kbd>i</kbd>                                           | 搜索 ignore 文本（比如 `.gitignore` 里的文本等）                      |
| glob 模式搜索        | 搜索框下按 <kbd>Ctrl</kbd> + <kbd>g</kbd>                                           | 搜索 glob 模式（比如 `**/*.js` 等）                                   |
| 筛选路径             | 搜索框下按 <kbd>Ctrl</kbd> + <kbd>f</kbd>                                           | 筛选路径                                                              |
| 冻结列表             | 搜索框下按 <kbd>Ctrl</kbd> + <kbd>space</kbd>                                       | 冻结列表，对列表进行二次搜索，比如可以使用 `!.lua` 排除指定的文件类型 |

## 🤖 AI 助手

本配置集成了多个 AI 插件，提供强大的 AI 编程辅助功能：

| 插件                                                                     | 功能                                                                | 提供商                                         |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------- | ---------------------------------------------- |
| **[avante.nvim](https://github.com/yetone/avante.nvim)**                 | AI 助手，支持代码解释、重构、优化等功能                             | Ollama、OpenRouter、Gemini、通义千问、Moonshot |
| **[llm.nvim](https://github.com/Kurama622/llm.nvim)**                    | 提供 LLM 交互，支持代码解释、翻译、代码优化、生成 Commit Message 等 | 智谱 AI (GLM-4)                                |
| **[supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim)** | AI 代码自动补全                                                     | Supermaven                                     |
| **[opencode.nvim](https://github.com/NickvanDyke/opencode.nvim)**        | AI 编程助手，支持代码理解和执行                                     | OpenCode                                       |

### 快捷键

| 功能                | 快捷键        | 描述                         |
| ------------------- | ------------- | ---------------------------- |
| **avante**          | -             | -                            |
| AI 对话             | `:AvanteChat` | 打开 AI 对话窗口             |
| **llm.nvim**        | -             | -                            |
| AI 聊天             | `<leader>ac`  | 切换 AI 聊天窗口             |
| 代码解释            | `<leader>ae`  | 解释选中的代码               |
| 翻译文本            | `<leader>at`  | 中英文互译选中文本           |
| 翻译器              | `<leader>aT`  | 打开翻译器窗口               |
| 优化代码（浮动）    | `<leader>ao`  | 在浮动窗口优化选中的代码     |
| 优化代码（Diff）    | `<leader>aO`  | 在 Diff 窗口优化选中的代码   |
| 生成 Commit Message | `<leader>ag`  | 根据 git diff 生成提交信息   |
| **supermaven**      | -             | -                            |
| 接受建议            | `<C-y>`       | 接受代码补全建议             |
| 清除建议            | `<C-]>`       | 清除当前建议                 |
| 接受单词            | `<C-w>`       | 接受下一个单词               |
| **opencode**        | -             | -                            |
| 提问                | `<C-a>`       | 向 AI 提问关于当前代码的问题 |
| 执行操作            | `<C-x>`       | 执行 AI 操作                 |
| 切换面板            | `<C-\>`       | 切换 opencode 面板           |

## 🎓 入门教程

本配置基于 LazyVim，如果你不了解它的用法，可以参考以下入门教程：

- [@elijahmanor](https://github.com/elijahmanor) 制作了一个很棒的视频，可以带领你快速入门。[![查看这个视频](https://img.youtube.com/vi/N93cTbtLCIM/hqdefault.jpg)](https://www.youtube.com/watch?v=N93cTbtLCIM)
- [@dusty-phillips](https://github.com/dusty-phillips) 为 LazyVim 编写了一本全面的书籍
  [《LazyVim for Ambitious Developers》](https://lazyvim-ambitious-devs.phillips.codes)
  ，可在线上免费阅读。

---

如果你想寻找一些有用的插件，可以访问以下网站：

- [neovimcraft](https://neovimcraft.com/)
- [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)

## 💬 其他问题

- 如何使用某个 commit 版本的插件？

  使用 <kbd>leader</kbd> + <kbd>l</kbd> + <kbd>r</kbd> 或者 `:Lazy restore` 命令将插件版本恢复到 lock 文件指定版本。

## 🛠️ 其他工具

- [kitty](https://sw.kovidgoyal.net/kitty/)
  - 0.37 版本支持鼠标追随动画（参考：[Cursor trails](https://sw.kovidgoyal.net/kitty/changelog/#cursor-trails-0-37)）
- [neovide](https://neovide.dev/)
  - 基于 Rust 编写，提供丝滑流程的 GUI 动画
