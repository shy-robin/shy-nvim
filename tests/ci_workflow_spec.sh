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
