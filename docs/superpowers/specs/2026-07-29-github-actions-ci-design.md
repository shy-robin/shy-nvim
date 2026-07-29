# GitHub Actions CI Design

**Date:** 2026-07-29

**Goal:** 为当前 Neovim 配置增加可复现的 GitHub Actions 检查，在最低支持版本和当前稳定版 Neovim 上复用仓库现有的统一验证入口。

## Scope

CI 在以下情况运行：

- push 到 `nvim-0.11`
- Pull Request 的目标分支为 `nvim-0.11`
- 通过 `workflow_dispatch` 手动触发

CI 不修改远端设置、不设置 GitHub 默认分支、不配置 required status check，也不提交或推送代码。

## Version Matrix

每次 workflow 分别使用：

- Neovim `v0.11.2`，覆盖 README 声明的最低版本
- Neovim `stable`，覆盖当前稳定版

两个矩阵任务相互独立，`fail-fast` 关闭，确保一个版本失败时仍能得到另一个版本的结果。

## Architecture

### Workflow

新增 `.github/workflows/test.yml`：

- 使用 Ubuntu runner
- 设置 `permissions: contents: read`
- 使用同一分支/PR 的 concurrency group，并取消旧运行
- 每个矩阵任务限制在 15 分钟内
- 安装固定版本的 Node、Python 和 StyLua
- 按矩阵安装 Neovim
- 准备最小 Lazy 插件快照
- 调用 `scripts/check.sh`

workflow 不复制 StyLua、Lua、JSON 或测试命令；`scripts/check.sh` 继续作为唯一检查入口。

### Minimal Plugin Bootstrap

新增 `scripts/bootstrap-test-plugins.sh`，接收一个目标目录：

1. 读取仓库 `lazy-lock.json`。
2. 提取 `lazy.nvim`、`LazyVim`、`snacks.nvim` 的锁定 commit。
3. 分别从官方 GitHub 仓库以 detached checkout 下载对应 commit。
4. 验证三个目标目录都已创建。
5. 输出可供 `NVIM_TEST_LAZY_ROOT` 使用的绝对路径。

只准备这三个插件，因为 `scripts/check.sh` 会把它们复制为只读快照，并在网络命令被屏蔽的环境中验证最终 Lazy spec、bigfile 和最小启动。CI 不执行完整 `:Lazy sync`，避免安装全部插件和运行无关构建。

## Dependencies

workflow 使用：

- `actions/checkout@v6`
- `actions/setup-node@v7`，Node 24
- `actions/setup-python@v7`，Python 3.13
- `rhysd/action-setup-vim@v1`
- `JohnnyMorganz/stylua-action@v5`，StyLua 2.0.2，`args: false`

第三方 action 只负责安装工具，不承载仓库测试逻辑。

## Error Handling

- bootstrap 缺少目标参数、锁文件条目或 commit 时立即失败。
- 任一仓库下载或 checkout 失败时立即失败。
- bootstrap 不接受已存在且非空的目标插件目录，防止混用旧快照。
- `scripts/check.sh` 的阶段名和退出码直接成为 CI 结果。
- workflow 使用最小只读 token 权限，不使用自定义 secrets；StyLua action 只接收 GitHub 自动提供的只读 `GITHUB_TOKEN`。

## Testing

先新增失败测试，再实现 workflow 和 bootstrap：

- `tests/ci_workflow_spec.sh` 静态解析 workflow，验证触发分支、手动触发、只读权限、双版本矩阵、超时、action 主版本、固定工具版本和 `scripts/check.sh` 调用。
- bootstrap 测试使用临时目录和伪造的 `git` 包装器，验证它只请求三个允许的仓库及锁定 commit，不访问网络。
- 将 CI 测试加入 `scripts/check.sh`，使本地与 GitHub Actions 使用同一套验证。
- 最后运行 `tests/ci_workflow_spec.sh`、`tests/check_runner_spec.sh` 和 `scripts/check.sh`。

## Non-Goals

- 不缓存全部 Neovim 插件。
- 不运行真实语言服务器、浏览器、外部上传或完整插件安装。
- 不测试 nightly Neovim。
- 不增加 macOS/Windows runner。
- 不修改 GitHub 仓库设置或分支保护。
