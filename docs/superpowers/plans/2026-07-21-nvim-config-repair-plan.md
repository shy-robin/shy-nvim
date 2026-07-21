# Neovim Configuration Repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复当前 Neovim 配置中未生效的插件选项、破坏性终端键位和 bigfile 状态泄漏，并逐步完善测试、懒加载、文档及跨平台保护。

**Architecture:** 保留现有 LazyVim 分层，不重写配置架构。每个批次独立完成测试、实现和验证，优先解决正确性，再处理状态生命周期、性能和维护性；功能修复、格式化和文档变更分开提交。

**Tech Stack:** Neovim 0.11.2+、Lua、LazyVim 16、lazy.nvim、nvim-lspconfig、Conform、Mason、Snacks、Node.js。

## Global Constraints

- 不新增非必要插件。
- 保留已验证的 Noice eager-load 与 bigfile `VimEnter` 竞态处理。
- 不恢复已移除的 Coc、ToggleTerm、OpenCode、Avante 或 llm.nvim。
- 每个批次独立验证；测试失败时不进入下一批次。
- 未经单独确认，不提交、不推送、不修改 GitHub 默认分支。
- 全仓库 StyLua 格式化必须是独立批次，不能混入功能修复。

---

## Priority Overview

| 优先级 | 任务 | 主要目标 | 风险 |
|---|---|---|---|
| P0-1 | 修正插件 spec | 让 LSP、Conform、Mason 自定义配置真正生效 | 中 |
| P0-2 | 修复 LazyGit 键位 | 恢复所有终端的标准 `<C-c>` | 低 |
| P1-1 | 完善 bigfile 生命周期 | 防止窗口和全局状态泄漏 | 中高 |
| P1-2 | 建立验证入口 | 覆盖最终 spec、bigfile 和最小启动 | 低 |
| P2-1 | 优化懒加载 | 删除冗余 `VeryLazy`，处理 scope.nvim | 中 |
| P2-2 | 清理迁移遗留 | 删除 Coc、旧 AI、ToggleTerm/OpenCode 残留 | 低 |
| P2-3 | 更新文档 | 对齐实际插件、版本、键位和维护分支 | 低 |
| P3-1 | 增强可移植性 | 保护外部命令和 Markdown Preview 构建 | 中 |
| P3-2 | 统一格式 | 全仓库 StyLua 并接入检查 | 低，diff 大 |

---

### Task 1（P0-1）：修正 LSP、Conform、Mason Plugin Spec

**Files:**
- Modify: `lua/plugins/lsp.lua`
- Modify: `lua/plugins/format.lua`
- Modify: `lua/plugins/conform.lua`
- Modify: `lua/plugins/mason.lua`
- Create: `tests/spec_opts_spec.lua`

**Produces:**
- `nvim-lspconfig.opts.servers` 包含仓库声明的服务器设置。
- `conform.nvim.opts.formatters_by_ft` 包含仓库声明的 formatter 矩阵。
- `mason.nvim.opts.ensure_installed` 包含仓库声明的工具清单。

- [ ] 为 lazy.nvim 最终合并配置编写失败测试，分别断言 `nvim-lspconfig`、`conform.nvim`、`mason.nvim` 的最终 opts。
- [ ] 运行测试，确认当前配置因 spec 归属错误而失败。
- [ ] 将 `lua/plugins/lsp.lua` 的目标从 `LazyVim/LazyVim` 改为 `neovim/nvim-lspconfig`，保留 `typescript_tools`、`volar`、`lua_ls`、`pyright`、`gopls` 设置。
- [ ] 删除 Volar 对启动时 `vim.fn.getcwd()` 的固定绑定，使用 LazyVim/Volar 的项目根目录解析。
- [ ] 核验 TypeScript extra 实际使用的 server 名称，避免配置未启用的 server。
- [ ] 将 `lua/plugins/format.lua` 的 Conform 配置并入 `stevearc/conform.nvim` spec，避免与 `lua/plugins/conform.lua` 分散维护。
- [ ] 将 Python formatter 改为依次执行 `isort`、`black`，不使用 `stop_after_first = true`。
- [ ] 将 Mason `ensure_installed` 与 UI 设置合并到 `mason-org/mason.nvim` spec。
- [ ] 核验 Mason registry 中的 `typescript-tools`、`rustfmt`、`sqlfmt` 等包名。
- [ ] 运行最终 opts 测试并确认通过。
- [ ] 打开 Lua、TypeScript、Vue、Python、Go 测试文件，检查 `:LspInfo`、`:ConformInfo`、`:Mason`。
- [ ] 确认 TypeScript/Vue 没有重复 LSP，Python import 排序与 Black 都执行。

**Risk:** 修正后原本被忽略的设置会首次真正生效，可能暴露无效 Mason 包名、重复 LSP 或新增诊断。

---

### Task 2（P0-2）：移除 LazyGit 全局终端 `<C-c>`

**Files:**
- Modify: `lua/plugins/lazygit.lua`

- [ ] 删除全局 terminal-mode `<C-c>` 映射。
- [ ] 删除失效的 `LLMAppHandler CommitMsg` 调用。
- [ ] 不在本任务中重新实现 AI Commit Message。
- [ ] 分别在普通 `:terminal`、Floaterm、LazyGit、Python/Node REPL 中运行长命令并按 `<C-c>`。
- [ ] 确认进程收到 SIGINT、窗口不关闭、没有 `Not an editor command`。

**Risk:** 低；只移除已经失效且会破坏所有终端的行为。

---

### Task 3（P1-1）：完善 Bigfile 状态生命周期

**Files:**
- Modify: `lua/config/options.lua`
- Modify: `lua/plugins/snacks.lua`
- Modify: `lua/plugins/supermaven.lua`
- Create: `tests/bigfile_spec.lua`

**Produces:**
- bigfile 进入和退出路径对称。
- 窗口级选项按原值恢复。
- Noice、MatchParen、Supermaven 等全局状态只在最后一个 bigfile 退出后恢复。

- [ ] 编写普通文件 → bigfile → 普通文件的失败测试。
- [ ] 编写两个 bigfile 同时存在并依次关闭的失败测试。
- [ ] 编写用户原本禁用 MatchParen、Supermaven 原本未启动的测试。
- [ ] 进入 bigfile 前按窗口保存 `foldmethod`、`foldenable`、`statuscolumn`、`conceallevel`、`cursorline`、`list`。
- [ ] 在切回普通 buffer 或窗口不再展示 bigfile 时恢复对应窗口原值。
- [ ] 只在 bigfile 确实关闭 MatchParen 时记录并恢复，不覆盖用户原始状态。
- [ ] 优先移除全局 `SupermavenStop`，依赖现有 buffer condition 禁用 bigfile；若插件行为要求全局停止，则加入引用计数和原始状态恢复。
- [ ] 保留当前 Noice disable/enable、`VimEnter` schedule、最后一个 bigfile 恢复和 `cmdheight` 顺序。
- [ ] 验证直接使用启动参数打开大文件时不会出现 hit-enter 卡死。
- [ ] 验证关闭 bigfile 后 `cmdheight=0`、内存 undo 可用、普通文件折叠和显示选项恢复。

**Risk:** 中高；同时涉及 buffer-local、window-local、全局状态以及启动时序，禁止在此任务顺便重构整个 bigfile 架构。

---

### Task 4（P1-2）：建立统一 Headless 验证入口

**Files:**
- Create: `tests/run.lua` or `scripts/check.sh`
- Create: `tests/minimal_init.lua`（如隔离运行需要）
- Modify: `tests/spec_opts_spec.lua`
- Modify: `tests/bigfile_spec.lua`
- Preserve: `tests/mkdp_spec.lua`
- Preserve: `tests/mkdp_route_fix_test.js`
- Optional Create: `.github/workflows/test.yml`

- [ ] 使用临时 `XDG_CONFIG_HOME`、`XDG_DATA_HOME`、`XDG_STATE_HOME`、`XDG_CACHE_HOME`，避免测试污染日常 Neovim 状态。
- [ ] 统一执行 Lua 语法检查和 JSON 解析。
- [ ] 统一执行现有 Markdown Preview Lua/Node 测试。
- [ ] 加入 Lazy 最终 plugin opts 测试。
- [ ] 加入 bigfile 进入/退出测试。
- [ ] 加入最小 headless 启动检查。
- [ ] 输出明确的失败阶段和退出码。
- [ ] 若增加 GitHub Actions，只提交仓库内 workflow；不修改远端设置。
- [ ] 暂不把 StyLua 设为强制通过，直到 Task 9 完成。

**Risk:** 低；主要风险是测试误写真实用户缓存，必须使用隔离 XDG 目录。

---

### Task 5（P2-1）：精简 `VeryLazy` 并处理 scope.nvim

**Files:**
- Modify: `lua/plugins/orgmode.lua`
- Modify: `lua/plugins/leetcode.lua`
- Modify: `lua/plugins/markdown-preview.lua`
- Modify: `lua/plugins/nvim-tree.lua`
- Modify: `lua/plugins/vim-floaterm.lua`
- Modify: `lua/plugins/comment-box.lua`
- Modify: `lua/plugins/img-clip.lua`
- Modify: `lua/plugins/translate.lua`
- Modify: `lua/plugins/nvim-picgo.lua`
- Modify or Delete: `lua/plugins/scope.lua`

- [ ] 记录优化前 `:Lazy profile` 和普通启动后的已加载插件数。
- [ ] 对已有 `keys`、`cmd`、`ft` 的插件删除冗余 `event = "VeryLazy"`。
- [ ] Markdown Preview 保留 `cmd`、`ft`、`keys`。
- [ ] Floaterm、Comment Box、Translate、img-clip、PicGo 使用精确命令或键位触发。
- [ ] Leetcode 改为命令、文件类型或显式键位触发，避免普通会话加载 Telescope 依赖。
- [ ] Orgmode 主要使用 `ft = "org"`，agenda/capture 使用显式命令或键位触发。
- [ ] 在修改 nvim-tree 前验证是否需要支持 `nvim some-directory/`；若需要，保留精确的目录参数启动路径。
- [ ] 确认是否仍需要每个 tab 独立 buffer；需要则为 scope.nvim 添加明确的 `VeryLazy` 触发，不需要则删除插件。
- [ ] 对比优化后 profile 和已加载插件数。
- [ ] 验证所有插件首次调用仍能加载，目录参数启动、Org agenda、Markdown Preview 和 scope 行为正常。

**Risk:** 中；不能机械删除所有 `VeryLazy`，部分插件依赖启动期 autocmd 或全局状态。

---

### Task 6（P2-2）：清理迁移遗留

**Files:**
- Modify: `lua/plugins/which-key.lua`
- Modify: `lua/plugins/lualine.lua`
- Modify: `lua/config/keymaps.lua`
- Modify: `lua/plugins/noice.lua`
- Modify: `lua/plugins/transparent.lua`
- Modify: `TODO.md`
- Modify: `CHANGELOG.md`
- Delete or update: `.migration_backup`（若仍跟踪）

- [ ] 删除 which-key 的 `+coc` 分组。
- [ ] 删除 Lualine 的 `g:coc_status` 组件。
- [ ] 清理 Coc、ToggleTerm、OpenCode、Avante、llm.nvim 的失效注释、命令和 TODO。
- [ ] 保留 Supermaven、Floaterm、Native LSP、Blink、fzf-lua 相关配置。
- [ ] 检查 `.migration_backup` 中的本机绝对路径，确认无用途后删除。
- [ ] 全仓库搜索 `coc`、`LLMAppHandler`、`opencode`、`toggleterm`、`avante`、`llm.nvim`，确认只剩必要的历史记录。
- [ ] 运行最小启动和现有测试。

**Risk:** 低；主要是删除无效展示、注释和死代码。

---

### Task 7（P2-3）：更新 README、版本和维护分支说明

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `TODO.md`

- [ ] 将主搜索器从 Telescope 更新为 fzf-lua，并更新当前键位说明。
- [ ] 将最低 Neovim 版本从 0.11.0 更新为 0.11.2。
- [ ] AI 插件列表只保留实际存在的 Supermaven。
- [ ] 终端方案更新为 Floaterm。
- [ ] 补充 Markdown Preview 所需 Node/npm/npx 依赖。
- [ ] 说明 `d/c/s/X/f/F` 等偏离标准 Vim 的个人化键位。
- [ ] clone 命令明确指定当前维护分支 `nvim-0.11`，除非用户另行决定切换 GitHub 默认分支。
- [ ] 更新 CHANGELOG/TODO 中已经完成或已经放弃的事项。
- [ ] 校验 README 中所有插件名称、URL、快捷键与当前实现一致。

**External action:** 修改 GitHub 默认分支需要独立确认，不属于本任务的默认执行范围。

**Risk:** 低。

---

### Task 8（P3-1）：增强外部命令和跨平台保护

**Files:**
- Modify: `lua/plugins/nvim-tree.lua`
- Modify: `lua/plugins/markdown-preview.lua`
- Modify: `lua/plugins/scissors.lua`
- Modify: `lua/plugins/vim-floaterm.lua`
- Modify: `README.md`

- [ ] 调用 `sips` 前使用 `vim.fn.executable("sips")` 检查；macOS 使用 sips，其他平台可选 ImageMagick `identify`，都不存在时省略图片尺寸。
- [ ] 按平台选择 `du` 参数，并保护 `vim.system()` 创建进程失败。
- [ ] Markdown Preview 构建前检查 `sh`、`node`、`npx`。
- [ ] 检查 Yarn 安装命令退出码，失败时停止后续 patch 并给出明确错误。
- [ ] patch 前检查目标文件存在，写入后检查结果，不再静默失败。
- [ ] 保留现有路由和 TOC patch 测试。
- [ ] 为 jq、ranger、yazi 等可选依赖增加条件加载或清晰错误提示。
- [ ] 更新 README 的平台能力和可选依赖说明。

**Risk:** 中；Markdown Preview 直接修改上游 checkout，错误处理调整不能破坏现有正常构建。

---

### Task 9（P3-2）：全仓库 StyLua 格式化

**Files:**
- Modify: `init.lua`
- Modify: `lua/**/*.lua`
- Modify: `tests/**/*.lua`

- [ ] 在独立批次运行 `stylua init.lua lua tests`。
- [ ] 检查 diff，确认只有格式变化。
- [ ] 运行所有功能测试和最小启动测试。
- [ ] 启用 `stylua --check init.lua lua tests` 作为统一检查和 CI 必须通过项。

**Risk:** 功能风险低，但 diff 较大；必须独立于任何功能修复。

---

## Recommended Execution Batches

### Batch 1：立即修复

1. Task 1：LSP/Conform/Mason spec
2. Task 2：LazyGit `<C-c>`

### Batch 2：稳定性与回归保障

3. Task 3：bigfile 状态恢复
4. Task 4：统一验证入口

### Batch 3：性能与维护

5. Task 5：VeryLazy/scope
6. Task 6：迁移遗留
7. Task 7：文档更新

### Batch 4：增强与质量

8. Task 8：跨平台保护
9. Task 9：全仓库格式化

## Execution Recommendation

优先执行 Batch 1。每个任务独立验证和汇报，不提交、不推送；Batch 1 通过后再决定是否进入 Batch 2。实施时推荐使用 `superpowers:subagent-driven-development`，每个任务完成后分别进行规格符合性和代码质量审查。
