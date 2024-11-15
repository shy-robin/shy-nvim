# ShyRobin's Neovim configuration

## 一、安装

- 安装 Neovim：`brew install neovim`
- 安装配置：`git clone https://github.com/shy-robin/shy-nvim.git ~/.config/nvim`

## 二、前置依赖

- 此配置依赖 [LazyVim](https://www.lazyvim.org/)，需要安装 LazyVim 的前置依赖（<https://www.lazyvim.org/#%EF%B8%8F-requirements>)
  - Nerd Font（安装并在 kitty 中配置使用）
  - lazygit（`brew install lazygit`）
  - ripgrep（`brew install ripgrep`）
  - fd（`brew install fd`）
- lsp 依赖 coc.nvim，需要安装 Node 环境
  - Nodejs（`brew install node`）
  - watchman（`brew install watchman`），volar 服务会用到，具体参考：<https://github.com/yaegassy/coc-volar?tab=readme-ov-file#recommended-additional-installation-of-watchman>
- python 依赖
  - ultisnips 需要依赖 python，因此需要提前安装 python，否则无法正常使用代码片段
    1. 安装 python：`brew install python`，检查是否安装成功：`python3 --version`
    2. 安装 pynvim：`pip3 install pynvim`，如果安装提示 ssl 的报错，需要断开 vpn 进行安装，检查是否安装成功：`python3` -> `import pynvim` -> `print(pynvim.__vesion__)`
    3. 检查 nvim 是否安装 python 环境：`:echo has('python3')`，若返回 1 则有，若为 0 则无

## TODO List

- [ ] 打开 nvim-tree，此时打开 floaterm，使用 <C-h> 或 <C-l> 切换会报错
- [ ] session manage https://docs.astronvim.com/mappings#session-manager-mappings
- [x] Dashboard(home) leader + h
- [ ] 自动上传剪切板图片到图库（[nvim-picgo](https://github.com/askfiy/nvim-picgo)）
- [x] 生成代码图片（[carbon-now.nvim](https://github.com/ellisonleao/carbon-now.nvim)）
- [x] 跳转链接（使用 gx）
- [ ] api 请求（[rest.nvim](https://github.com/rest-nvim/rest.nvim) 或 [kulala.nvim](https://github.com/mistweaverco/kulala.nvim))
- [ ] 翻译（[translate.nvim](https://github.com/uga-rosa/translate.nvim)）
- [ ] 注释画图（[venn.nvim](https://github.com/jbyuki/venn.nvim)）
- [x] zf 无效（使用 nvim-ufo 解决）
- [ ] 自定义折叠区域，#region #endregion
- [x] 快速聚焦到 nvim-tree（使用 <leader>e 切换）
- [x] common snippets eg. markdown
- [ ] nvim tree open from cwd
- [ ] quit session so slow
- [ ] 整理快捷键，group -> +group, item -> Item
- [x] 添加 markdown 快捷键
- [x] git sign 位置，以及 图标重合问题
- [x] theme
- [ ] telescope 搜索全局，monorepo 项目子项目路径自动切换，如何搜根目录？
- [x] format eslint
  - [x] leader f n
  - [x] leader f s 自动格式化
  - [x] leader f e eslint autofix
- [x] buffer 切换快捷键，多 tab
- [ ] tmux server error
- [x] event = very lazy
- [x] linter
- [x] eslint autofix
- [x] color not work
- [x] code fold
- [x] current cursor not underline
- [x] multi cursor
- [ ] mark
- [x] eslint_d
- [x] ufo
- [x] statuscolumn
- [x] eslint fix all bug 需要调出 lazygit 才能刷新 buffer
- [x] spell check
- [x] clipboard history
- [ ] line wrap
- [x] vue template emmet div.region-recommend
- [x] lua snip <div cl></div cl>
- [x] import @
- [x] tag new line, see: vim.g.formatoptions
- [x] format lose content
- [x] remove notify use cmdline
- [x] in vue import not cmp
- [x] 美化加边框，which key or mason lsp
- [x] use cmdline
- [x] cmp format 加来源，close ghost text
- [x] cmp cmdline 加 cmdline source
- [x] cmp search 加 buffer source
- [ ] easy-commands <https://www.bilibili.com/video/BV1EV411G7UK/?spm_id_from=333.788.recommend_more_video.1&vd_source=4ef7b6657238565af69458e77de87682>
- [x] diff-view
- [x] startup time optimize
- [x] undo tree
- [x] coc
- [x] coc expand snippet c-j?
- [ ] coc lua neodev not work
- [x] coc lsp progress
- [x] coc cmdline cmp
- [x] bufferline top Always show
- [x] lualine sometimes show
- [ ] random plugin (autocmd ??)
- [x] telescope live grep args
- [x] markup
- [x] comment error
- [x] vim native tab
- [x] dap
- [x] nvim-tree auto center
- [x] fix gitsigns not show
- [x] bookmark
- [x] outline
- [x] gitsigns vs fugitive
- [x] hop

## 插件

添加 lua 文件的位置：
nvim --cmd "set rtp+=xxx"

:lua require("xxx")

### lazy-nvim

### neo-tree

直接查看配置文档：
:h Neotree

### nvim-window-picker

## lua 教程

## 资源

<https://neovimcraft.com/>

<https://github.com/rockerBOO/awesome-neovim>

## 添加 lsp

在 mason.lua 里添加自动安装的 lsp 并保存，下次启动 nvim 时会自动安装；
使用 <leader>cm 查看安装进度；
在打开对应的文件，使用 <leader>cl 查看对应的 lsp 是否生效。

## lua-snip

教程：<https://www.ejmastnak.com/tutorials/vim-latex/luasnip/#tips>

## Vim Register

<https://www.brianstorti.com/vim-registers/>

### 使用寄存器

1. Normal Mode: `"`
2. Insert/Command Mode: `Control + r`

### 寄存器种类

1. 匿名寄存器（unnamed register)
   `""`
2. 数字寄存器 (numbered registers)
   `"0-9`
   0 存储最近一次复制的文本
   1-9 存储最近操作的文本
3. 字母寄存器
   `"a-z`
   使用大写字母可以向对应的小写字母寄存器里增加内容
4. 只读寄存器 (read-only registers)

- `".` 存储上一次插入的文本
- `"%` 存储当前文件路径
- `"#` 存储上一个文件路径
- `":` 存储最近一次命令
- `"/` 存储最近一次搜索文本

### 修改寄存器内容

`let @j='xxx'`
`let @j=@+`

### 宏

1. 记录宏 qj ... q
2. 应用宏 @j

使用宏的内容 "j

记录的宏也是作为文本存储到寄存器里。
也可以通过修改寄存器的方法，修改宏的内容。

`let @j='xxxx'`
