# GitHub Actions CI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 Neovim v0.11.2 与 stable 上，为 `nvim-0.11` 分支增加复用 `scripts/check.sh` 的 GitHub Actions CI。

**Architecture:** workflow 只负责安装固定工具、按 `lazy-lock.json` 准备三个最小测试插件并调用统一检查入口。独立 bootstrap 脚本负责锁定插件快照，Shell 回归测试在无网络的伪 Git 环境中验证 bootstrap 和 workflow 合约。

**Tech Stack:** GitHub Actions、Bash、Python 3、Neovim、StyLua、lazy.nvim。

## Global Constraints

- push 到 `nvim-0.11`、目标为 `nvim-0.11` 的 Pull Request 和 `workflow_dispatch` 才触发。
- 测试矩阵固定为 Neovim `v0.11.2` 与 `stable`，`fail-fast: false`。
- workflow 权限固定为 `contents: read`，不使用自定义 secrets；StyLua action 只接收 GitHub 自动提供的只读 `GITHUB_TOKEN`。
- Node 固定为 24，Python 固定为 3.13，StyLua 固定为 2.0.2。
- 只下载 `lazy.nvim`、`LazyVim`、`snacks.nvim`，commit 必须来自 `lazy-lock.json`。
- `scripts/check.sh` 是唯一功能检查入口，workflow 不复制测试命令。
- 不执行完整 `:Lazy sync`，不增加 macOS、Windows 或 nightly。
- 不修改 GitHub 远端设置、默认分支或分支保护。
- 未经用户单独确认，不创建 commit、不 push。

---

### Task 1: 最小 Lazy 插件 Bootstrap

**Files:**
- Create: `scripts/bootstrap-test-plugins.sh`
- Create: `tests/ci_workflow_spec.sh`

**Interfaces:**
- Consumes: `lazy-lock.json` 中 `lazy.nvim`、`LazyVim`、`snacks.nvim` 的 `.commit` 字段。
- Produces: `scripts/bootstrap-test-plugins.sh TARGET_ROOT`；成功时 stdout 最后一行为 `TARGET_ROOT` 的绝对路径，目录下包含三个 detached Git checkout。

- [ ] **Step 1: 编写 bootstrap 失败测试**

创建 `tests/ci_workflow_spec.sh`：

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
bootstrap="$repo_dir/scripts/bootstrap-test-plugins.sh"
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/nvim-ci-workflow-spec.XXXXXX")

cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[ -x "$bootstrap" ] || fail "bootstrap script must be executable: $bootstrap"

fake_bin="$work_dir/bin"
git_log="$work_dir/git.log"
mkdir -p "$fake_bin"
cat >"$fake_bin/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$CI_SPEC_GIT_LOG"
if [ "${1:-}" = "-C" ]; then
  cwd=$2
  shift 2
else
  cwd=$PWD
fi
command=${1:-}
shift || true
case "$command" in
  init)
    mkdir -p "$cwd/.git"
    ;;
  remote)
    ;;
  fetch)
    printf '%s\n' "${!#}" >"$cwd/.fake-commit"
    ;;
  checkout)
    ;;
  rev-parse)
    cat "$cwd/.fake-commit"
    ;;
  *)
    printf 'unexpected fake git command: %s\n' "$command" >&2
    exit 91
    ;;
esac
EOF
chmod +x "$fake_bin/git"

target="$work_dir/plugins"
output=$(
  PATH="$fake_bin:$PATH" \
    CI_SPEC_GIT_LOG="$git_log" \
    "$bootstrap" "$target"
)
[ "$output" = "$(cd "$target" && pwd -P)" ] || fail "bootstrap must print the absolute target root"

for plugin in lazy.nvim LazyVim snacks.nvim; do
  [ -d "$target/$plugin/.git" ] || fail "missing plugin checkout: $plugin"
done

for expected in \
  'https://github.com/folke/lazy.nvim.git' \
  'https://github.com/LazyVim/LazyVim.git' \
  'https://github.com/folke/snacks.nvim.git'; do
  grep -F -- "$expected" "$git_log" >/dev/null || fail "missing repository request: $expected"
done

python3 - "$repo_dir/lazy-lock.json" "$git_log" <<'PY'
import json
import sys

lock_path, log_path = sys.argv[1:]
with open(lock_path, encoding="utf-8") as source:
    lock = json.load(source)
with open(log_path, encoding="utf-8") as source:
    log = source.read()
for name in ("lazy.nvim", "LazyVim", "snacks.nvim"):
    commit = lock[name]["commit"]
    if commit not in log:
        raise SystemExit("missing locked commit for {}: {}".format(name, commit))
PY

nonempty="$work_dir/nonempty"
mkdir -p "$nonempty/lazy.nvim"
printf 'sentinel\n' >"$nonempty/lazy.nvim/keep"
if PATH="$fake_bin:$PATH" CI_SPEC_GIT_LOG="$git_log" "$bootstrap" "$nonempty" >/dev/null 2>&1; then
  fail "bootstrap must reject an existing nonempty plugin directory"
fi
[ "$(cat "$nonempty/lazy.nvim/keep")" = sentinel ] || fail "bootstrap modified an existing plugin directory"

printf 'OK CI bootstrap uses the three locked plugin commits\n'
```

- [ ] **Step 2: 运行测试，确认因 bootstrap 不存在而失败**

Run:

```bash
bash tests/ci_workflow_spec.sh
```

Expected:

```text
FAIL: bootstrap script must be executable
```

- [ ] **Step 3: 实现最小 bootstrap**

创建 `scripts/bootstrap-test-plugins.sh`：

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
  printf 'usage: %s TARGET_ROOT\n' "${0##*/}" >&2
  exit 64
fi

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
lock_file="$repo_dir/lazy-lock.json"
target_root=$1

for command_name in git python3 mkdir find; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'ERROR: required command not found: %s\n' "$command_name" >&2
    exit 127
  }
done
[ -f "$lock_file" ] || {
  printf 'ERROR: lock file not found: %s\n' "$lock_file" >&2
  exit 1
}

mkdir -p "$target_root"
target_root=$(cd "$target_root" && pwd -P)

plugins=(
  'lazy.nvim|https://github.com/folke/lazy.nvim.git'
  'LazyVim|https://github.com/LazyVim/LazyVim.git'
  'snacks.nvim|https://github.com/folke/snacks.nvim.git'
)

for entry in "${plugins[@]}"; do
  name=${entry%%|*}
  url=${entry#*|}
  commit=$(python3 - "$lock_file" "$name" <<'PY'
import json
import sys

lock_path, name = sys.argv[1:]
with open(lock_path, encoding="utf-8") as source:
    lock = json.load(source)
commit = lock.get(name, {}).get("commit")
if not isinstance(commit, str) or len(commit) != 40:
    raise SystemExit("missing valid commit for {}".format(name))
print(commit)
PY
)
  plugin_dir="$target_root/$name"
  if [ -e "$plugin_dir" ] && [ -n "$(find "$plugin_dir" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    printf 'ERROR: plugin directory is not empty: %s\n' "$plugin_dir" >&2
    exit 1
  fi
  mkdir -p "$plugin_dir"
  git -C "$plugin_dir" init -q
  git -C "$plugin_dir" remote add origin "$url"
  git -C "$plugin_dir" fetch --depth 1 origin "$commit"
  git -C "$plugin_dir" checkout --detach -q FETCH_HEAD
  actual=$(git -C "$plugin_dir" rev-parse HEAD)
  [ "$actual" = "$commit" ] || {
    printf 'ERROR: checkout mismatch for %s: expected %s, got %s\n' "$name" "$commit" "$actual" >&2
    exit 1
  }
done

printf '%s\n' "$target_root"
```

设置可执行位：

```bash
chmod +x scripts/bootstrap-test-plugins.sh tests/ci_workflow_spec.sh
```

- [ ] **Step 4: 运行测试，确认 bootstrap 通过**

Run:

```bash
bash tests/ci_workflow_spec.sh
```

Expected:

```text
OK CI bootstrap uses the three locked plugin commits
```

- [ ] **Step 5: 检查本任务 diff**

Run:

```bash
git diff --check
git status --short
```

Expected: 无 whitespace error；只出现设计/计划文档、bootstrap 和 CI 测试文件。未经单独确认不 commit。

---

### Task 2: GitHub Actions Workflow

**Files:**
- Modify: `tests/ci_workflow_spec.sh`
- Create: `.github/workflows/test.yml`

**Interfaces:**
- Consumes: Task 1 的 `scripts/bootstrap-test-plugins.sh TARGET_ROOT`。
- Produces: GitHub Actions workflow `Test / check (v0.11.2)` 与 `Test / check (stable)`。

- [ ] **Step 1: 在 CI 测试中加入 workflow 合约断言**

在 `tests/ci_workflow_spec.sh` 的最终成功输出前加入：

```bash
workflow="$repo_dir/.github/workflows/test.yml"
[ -f "$workflow" ] || fail "workflow must exist: $workflow"

assert_workflow() {
  pattern=$1
  label=$2
  grep -F -- "$pattern" "$workflow" >/dev/null || fail "workflow missing $label: $pattern"
}

assert_workflow 'branches: [nvim-0.11]' 'maintenance branch trigger'
assert_workflow 'workflow_dispatch:' 'manual trigger'
assert_workflow 'contents: read' 'read-only contents permission'
assert_workflow 'cancel-in-progress: true' 'stale run cancellation'
assert_workflow 'fail-fast: false' 'complete matrix results'
assert_workflow 'neovim: [v0.11.2, stable]' 'Neovim version matrix'
assert_workflow 'timeout-minutes: 15' 'job timeout'
assert_workflow 'actions/checkout@v6' 'checkout action'
assert_workflow 'actions/setup-node@v7' 'Node setup action'
assert_workflow 'node-version: 24' 'Node version'
assert_workflow 'actions/setup-python@v7' 'Python setup action'
assert_workflow "python-version: '3.13'" 'Python version'
assert_workflow 'rhysd/action-setup-vim@v1' 'Neovim setup action'
assert_workflow 'version: ${{ matrix.neovim }}' 'matrix Neovim installation'
assert_workflow 'JohnnyMorganz/stylua-action@v5' 'StyLua setup action'
assert_workflow 'token: ${{ secrets.GITHUB_TOKEN }}' 'StyLua read-only GitHub token'
assert_workflow 'version: 2.0.2' 'StyLua version'
assert_workflow 'args: false' 'StyLua install-only mode'
assert_workflow './scripts/bootstrap-test-plugins.sh "$RUNNER_TEMP/nvim-check-lazy"' 'minimal plugin bootstrap'
assert_workflow 'NVIM_TEST_LAZY_ROOT: ${{ runner.temp }}/nvim-check-lazy' 'plugin snapshot environment'
assert_workflow './scripts/check.sh' 'unified check runner'

if grep -F -- 'Lazy sync' "$workflow" >/dev/null; then
  fail "workflow must not perform a full Lazy sync"
fi

printf 'OK CI bootstrap and workflow use locked dependencies and the unified check runner\n'
```

把 Task 1 的旧成功输出删除，保证测试只输出新的最终成功行。

- [ ] **Step 2: 运行测试，确认因 workflow 不存在而失败**

Run:

```bash
bash tests/ci_workflow_spec.sh
```

Expected:

```text
FAIL: workflow must exist
```

- [ ] **Step 3: 创建最小 workflow**

创建 `.github/workflows/test.yml`：

```yaml
name: Test

on:
  push:
    branches: [nvim-0.11]
  pull_request:
    branches: [nvim-0.11]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: test-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    name: check (${{ matrix.neovim }})
    runs-on: ubuntu-latest
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        neovim: [v0.11.2, stable]
    steps:
      - name: Checkout repository
        uses: actions/checkout@v6

      - name: Set up Node.js
        uses: actions/setup-node@v7
        with:
          node-version: 24
          package-manager-cache: false

      - name: Set up Python
        uses: actions/setup-python@v7
        with:
          python-version: '3.13'

      - name: Set up Neovim
        uses: rhysd/action-setup-vim@v1
        with:
          neovim: true
          version: ${{ matrix.neovim }}

      - name: Set up StyLua
        uses: JohnnyMorganz/stylua-action@v5
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: 2.0.2
          args: false

      - name: Prepare locked test plugins
        run: ./scripts/bootstrap-test-plugins.sh "$RUNNER_TEMP/nvim-check-lazy"

      - name: Run repository checks
        env:
          NVIM_TEST_LAZY_ROOT: ${{ runner.temp }}/nvim-check-lazy
        run: ./scripts/check.sh
```

- [ ] **Step 4: 运行 workflow 合约测试**

Run:

```bash
bash tests/ci_workflow_spec.sh
```

Expected:

```text
OK CI bootstrap and workflow use locked dependencies and the unified check runner
```

- [ ] **Step 5: 校验 YAML 基本结构**

Run:

```bash
python3 - <<'PY'
from pathlib import Path

text = Path(".github/workflows/test.yml").read_text(encoding="utf-8")
assert "\t" not in text
assert text.endswith("\n")
assert text.count("uses:") == 5
print("OK workflow basic structure")
PY
```

Expected:

```text
OK workflow basic structure
```

未经单独确认不 commit。

---

### Task 3: 接入统一检查并完成回归验证

**Files:**
- Modify: `scripts/check.sh`
- Modify: `tests/check_runner_spec.sh`

**Interfaces:**
- Consumes: Task 1–2 的 `tests/ci_workflow_spec.sh`。
- Produces: `scripts/check.sh` 中名为 `tests/ci_workflow_spec.sh` 的明确验证阶段。

- [ ] **Step 1: 先扩展 runner 回归测试**

在 `tests/check_runner_spec.sh` 的成功阶段列表中，在 `external_commands_spec.lua` 后加入：

```bash
  'ci_workflow_spec.sh' \
```

- [ ] **Step 2: 运行 runner 测试，确认因统一入口尚未执行 CI 测试而失败**

Run:

```bash
bash tests/check_runner_spec.sh
```

Expected:

```text
FAIL: missing output: ci_workflow_spec.sh
```

- [ ] **Step 3: 将 CI 测试加入统一入口**

在 `scripts/check.sh` 的 `tests/external_commands_spec.lua` 阶段后加入：

```bash
run_stage 'tests/ci_workflow_spec.sh' "$repo_dir/tests/ci_workflow_spec.sh"
```

- [ ] **Step 4: 运行 runner 与 CI 专项测试**

Run:

```bash
bash tests/ci_workflow_spec.sh
bash tests/check_runner_spec.sh
```

Expected:

```text
OK CI bootstrap and workflow use locked dependencies and the unified check runner
OK check runner uses isolated read-only plugin snapshots and propagates failures
```

- [ ] **Step 5: 运行完整统一检查**

Run:

```bash
./scripts/check.sh
```

Expected: 所有阶段通过，并包含：

```text
CHECK: tests/ci_workflow_spec.sh
OK CI bootstrap and workflow use locked dependencies and the unified check runner
SUCCESS: all local validation stages passed; temporary XDG removed
```

- [ ] **Step 6: 最终静态检查**

Run:

```bash
git diff --check
git status --short
```

Expected:

- 无 whitespace error。
- 只包含本计划声明的文档、workflow、bootstrap、测试和统一入口变更。
- 未创建 commit、未 push、未修改远端设置。
