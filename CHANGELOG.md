# Changelog

所有对此项目的重大更改都将记录在此文件中。
该项目遵循[语义化版本控制](https://semver.org/spec/v2.0.0.html)。

## [unreleased]

### To be added

- [ ] org-mode 支持 或者 neorg 支持
- [ ] 生成注释（使用 neogen 或者 snippet），如 jsdoc，以及文件注释（如文件作者，描述等信息）
- [ ] 回退上次跳转文件（使用 `<leader>sj` 查找 jump list）
- [ ] fzf 持久化 (fzf 暂不支持)
- [ ] colorizer-picker
- [x] 折叠代码区域，vscode 里的 #region #endregion 范围内折叠
  - 暂时无法实现（参考：<https://github.com/kevinhwang91/nvim-ufo/issues/233>）
  - 代替方法：visual mode 选中多行代码，使用 `zf` 折叠
- [ ] 生成随机的字符（人名、邮箱、诗句等）
- [ ] easy-commands（<https://www.bilibili.com/video/BV1EV411G7UK/?spm_id_from=333.788.recommend_more_video.1&vd_source=4ef7b6657238565af69458e77de87682>）
- [ ] 会话管理（<https://docs.astronvim.com/mappings#session-manager-mappings>）
- [ ] api 请求（[rest.nvim](https://github.com/rest-nvim/rest.nvim) 或 [kulala.nvim](https://github.com/mistweaverco/kulala.nvim))
- [ ] 翻译（[translate.nvim](https://github.com/uga-rosa/translate.nvim)）
- [ ] 注释画图（[venn.nvim](https://github.com/jbyuki/venn.nvim)）
- [ ] lualine 闪烁问题（<https://github.com/nvim-lualine/lualine.nvim/issues/1280>）

### To be fixed

- [x] 主题持久化 [b0cf6ac]
- [x] 移除 markdown spell check [ab2da2a]
- [x] colorizer [646ba4c]

## [1.1.0](https://github.com/shy-robin/shy-nvim/compare/v1.0.3...v1.1.0) (2025-01-04)

### Added

- 增加 `leetcode.nvim` 插件

### Changed

- 升级 LazyVim 至 14.x
- 使用 `Snacks.indent` 代替 `indent-blankline.nvim`
- 禁用 LazyVim 默认的 `blink.cmp` （与 `coc` 冲突）
- 使用 `fzf.lua` 代替 `telescope.nvim`
- 移除不常用、异常的主题插件
- 修改 lualine 的样式

### Fixed

- 初始化时，lualine 的背景色失效问题 [b66ad56]

## [1.0.3](https://github.com/shy-robin/shy-nvim/compare/v1.0.2...v1.0.3) (2024-12-08)

### Added

- 增加 Supermaven 插件，用于 AI 代码续写
- 增加 CHANGELOG.md 文件
- 增加 `<leader>ll` 快捷键组合，用于打开 LazyVim

### Changed

- 默认开启所有插件 lazy 加载
- llm.nvim 修改交互样式
- 修改 markdown-preview.nvim 的默认配置

### Fixed

- 修复 live greps 时无法使用 `<C-f>` 搜索文件的问题
- `<leader>e` 打开 nvim-tree，此时 `<C-o>` 打开 floaterm，使用 `<C-h>` 或 `<C-l>` 切换会报错
  - [fix(#3018): error when focusing nvim-tree when in terminal mode (#3019)](https://github.com/nvim-tree/nvim-tree.lua/commit/db8d7ac1f524fc6f808764b29fa695c51e014aa6)

## [1.0.2](https://github.com/shy-robin/shy-nvim/compare/v1.0.1...v1.0.2) (2024-12-06)

### Added

- 添加 llm.nvim 插件，用于调用 openai api
- 搜索文件支持 `<C-i>` 搜索忽略文件，`<C-u>` 搜索隐藏文件
- 搜索文本支持 `<C-y>` 增加引号，`<C-i>` 搜索忽略文本，`<C-g>` 搜索 glob 模式，`<C-space>` 过滤路径

### Changed

- 打开 lua 文件，会提示 `StyLua v2.0.1 is available to install.`，初步定位是 coc 的问题
  - `"stylua.checkUpdate": false` 关闭更新检查

### Fixed

- 修复 nvim-tree 打开时，无法使用 `<C-f>` 搜索文件的问题
- 修复切换背景透明时，coc 弹窗，floaterm 和 lualine 的背景颜色和边框颜色不透明的问题
  - coc 弹窗未找到 highlight group ，暂时未清除

## [1.0.1](https://github.com/shy-robin/shy-nvim/compare/v1.0.0...v1.0.1) (2024-12-05)

### Added

- 添加一些切换命令
  - `<leader>ub` 切换透明背景
  - `<leader>ud` 切换是否显示 coc 的诊断
  - `<leader>uh` 切换是否显示 coc 的 inlay hint
  - `<leader>uS` 切换是否显示 coc 的拼接检查
  - `<leader>CC` 切换是否开启 coc
- 使用 LazyVim 的 neogen extras 支持自动生成类型注释
- 使用 LazyVim 的 harpoon2 extras 支持快速打开文件
- 使用 Snacks.nvim 提供的 dashboard , bigfile, statuscol 等模块
- 添加 carbon-now.nvim 插件，生成代码图片
- 添加 wakatime 插件，用于统计代码行数
- 添加 vscode 主题
- 添加 transparent.nvim 插件，用于切换透明背景
- 添加 nvim-picgo 插件，用于自动上传剪切板图片到图库

### Changed

- 修改 README.md 文件
- 去除高亮 `<leader>nh` → `<leader>ur` (LazyVim 默认映射)
- 覆盖 LazyVim 默认的 lazygit 快捷键，防止样式被默认的覆盖

### Fixed

- 删除默认配置，不然快速按下 `<leader>wr` 不会触发
- 退出时移除所有 floaterm，解决 `<leader>qq` 退出卡顿的问题

## [1.0.0](https://github.com/shy-robin/shy-nvim/releases/tag/v1.0.0) (2024-08-31)

- Initial release
