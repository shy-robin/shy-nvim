#!/usr/bin/env bash
# Run directly: bash tests/check_runner_spec.sh
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
runner="$repo_dir/scripts/check.sh"
lazy_root=${NVIM_TEST_LAZY_ROOT:-"$HOME/.local/share/nvim/lazy"}
[ -d "$lazy_root/lazy.nvim" ] || {
  printf 'FAIL: NVIM_TEST_LAZY_ROOT must point to installed lazy plugins: %s\n' "$lazy_root" >&2
  exit 1
}
lazy_root=$(cd "$lazy_root" && pwd -P)
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/nvim-check-runner-spec.XXXXXX")

cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  file=$1
  text=$2
  grep -F -- "$text" "$file" >/dev/null || fail "missing output: $text"
}

assert_no_caller_xdg_writes() {
  caller_root=$1
  for path in "$caller_root/config/nvim" "$caller_root/data/nvim" "$caller_root/state/nvim" "$caller_root/cache/nvim"; do
    [ ! -e "$path" ] || fail "runner wrote caller XDG path: $path"
  done
}

assert_removed_mktemp_roots() {
  while IFS= read -r temp_root; do
    [ ! -e "$temp_root" ] || fail "runner did not clean temporary root: $temp_root"
  done <"$mktemp_log"
}

[ -x "$runner" ] || fail "check runner must exist and be executable: $runner"

wrapper_dir="$work_dir/bin"
mkdir -p "$wrapper_dir"
mktemp_log="$work_dir/mktemp.log"
nvim_log="$work_dir/nvim.log"
real_nvim=$(command -v nvim)
real_git=$(command -v git)

cat >"$wrapper_dir/mktemp" <<'EOF'
#!/bin/sh
result=$(/usr/bin/mktemp "$@") || exit $?
printf '%s\n' "$result" >>"$CHECK_RUNNER_MKTEMP_LOG"
printf '%s\n' "$result"
EOF
chmod +x "$wrapper_dir/mktemp"

cat >"$wrapper_dir/git" <<'EOF'
#!/bin/sh
case " $* " in
  *' clone '*|*' fetch '*|*' pull '*)
    printf 'blocked external git operation: %s\n' "$*" >&2
    exit 90
    ;;
esac
exec "$CHECK_RUNNER_REAL_GIT" "$@"
EOF
chmod +x "$wrapper_dir/git"

cat >"$wrapper_dir/nvim" <<'EOF'
#!/bin/sh
snapshot=$NVIM_TEST_LAZY_ROOT
source_root=$CHECK_RUNNER_SOURCE_LAZY_ROOT
case "$snapshot" in
  "$source_root"|"$source_root"/*)
    printf 'runner exposed real lazy root to Neovim: %s\n' "$snapshot" >&2
    exit 91
    ;;
esac
[ -d "$snapshot/lazy.nvim" ] || exit 92
[ -d "$snapshot/LazyVim" ] || exit 92
[ -d "$snapshot/snacks.nvim" ] || exit 92
[ ! -L "$snapshot/lazy.nvim" ] || exit 93
[ ! -L "$snapshot/LazyVim" ] || exit 93
[ ! -L "$snapshot/snacks.nvim" ] || exit 93
[ ! -w "$snapshot" ] || {
  printf 'runner exposed writable plugin snapshot: %s\n' "$snapshot" >&2
  exit 94
}
for plugin in lazy.nvim LazyVim snacks.nvim; do
  [ ! -w "$snapshot/$plugin" ] || exit 94
done
for entry in "$snapshot"/*; do
  case ${entry##*/} in
    lazy.nvim|LazyVim|snacks.nvim) ;;
    *) printf 'runner copied an unexpected plugin: %s\n' "$entry" >&2; exit 96 ;;
  esac
done
case "$XDG_DATA_HOME/nvim/lazy" in
  *) [ -L "$XDG_DATA_HOME/nvim/lazy" ] || exit 95 ;;
esac
[ "$snapshot" -ef "$XDG_DATA_HOME/nvim/lazy" ] || exit 95
case ":$PATH:" in
  *'/blocked-bin:'*) ;;
  *) printf 'runner did not restrict Neovim PATH\n' >&2; exit 97 ;;
esac
printf '%s|%s|%s|%s|%s|%s|%s\n' "$snapshot" "$HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$TMPDIR" >>"$CHECK_RUNNER_NVIM_LOG"
if [ "${CHECK_RUNNER_FAIL_FIRST_LUA_TEST:-}" = 1 ]; then
  case " $* " in
    *' +luafile tests/mkdp_spec.lua '*)
      set -- --headless -u NORC "+luafile $CHECK_RUNNER_FAILING_LUA_TEST" +qa
      ;;
    *'dofile(vim.env.NVIM_CHECK_LUA_TEST_LOADER)'*)
      NVIM_CHECK_LUA_TEST=$CHECK_RUNNER_FAILING_LUA_TEST
      export NVIM_CHECK_LUA_TEST
      ;;
  esac
fi
exec "$CHECK_RUNNER_REAL_NVIM" "$@"
EOF
chmod +x "$wrapper_dir/nvim"

external_bin="$work_dir/external-bin"
mkdir -p "$external_bin"
ln -s "$runner" "$external_bin/check.sh"

caller_root="$work_dir/caller-xdg"
outside_dir="$work_dir/outside"
mkdir -p "$caller_root/config" "$caller_root/data" "$caller_root/state" "$caller_root/cache" "$caller_root/home" "$outside_dir"
printf 'config sentinel\n' >"$caller_root/config/sentinel"
printf 'data sentinel\n' >"$caller_root/data/sentinel"
printf 'state sentinel\n' >"$caller_root/state/sentinel"
printf 'cache sentinel\n' >"$caller_root/cache/sentinel"

source_hashes_before="$work_dir/source-before.sha"
source_hashes_after="$work_dir/source-after.sha"
find "$lazy_root/lazy.nvim" "$lazy_root/LazyVim" "$lazy_root/snacks.nvim" -type f -exec shasum {} \; >"$source_hashes_before"
relative_lazy_root=$(cd "$outside_dir" && python3 -c 'import os, sys; print(os.path.relpath(sys.argv[1]))' "$lazy_root")

success_output="$work_dir/success.out"
(
  cd "$outside_dir"
  PATH="$wrapper_dir:$external_bin:$PATH" \
    CHECK_RUNNER_REAL_GIT="$real_git" \
    CHECK_RUNNER_REAL_NVIM="$real_nvim" \
    CHECK_RUNNER_SOURCE_LAZY_ROOT="$lazy_root" \
    CHECK_RUNNER_MKTEMP_LOG="$mktemp_log" \
    CHECK_RUNNER_NVIM_LOG="$nvim_log" \
    HOME="$caller_root/home" \
    XDG_CONFIG_HOME="$caller_root/config" \
    XDG_DATA_HOME="$caller_root/data" \
    XDG_STATE_HOME="$caller_root/state" \
    XDG_CACHE_HOME="$caller_root/cache" \
    NVIM_TEST_LAZY_ROOT="$relative_lazy_root" \
    check.sh
) >"$success_output" 2>&1

for stage in \
  'Lua syntax' \
  'JSON parsing' \
  'mkdp_spec.lua' \
  'mkdp_route_fix_test.js' \
  'lazygit_spec.lua' \
  'spec_opts_spec.lua' \
  'migration_cleanup_spec.lua' \
  'bigfile_spec.lua' \
  'minimal headless startup' \
  'SUCCESS:'; do
  assert_contains "$success_output" "$stage"
done
if grep -F -- 'blocked external git operation' "$success_output" >/dev/null; then
  fail 'runner attempted a blocked external git operation'
fi
[ -s "$nvim_log" ] || fail 'runner did not start Neovim through the isolated snapshot wrapper'
process_homes=''
while IFS='|' read -r snapshot process_home process_config process_data process_state process_cache process_tmp; do
  process_root=${process_home%/home}
  case "|$process_homes|" in
    *"|$process_home|"*) fail "runner reused Neovim HOME: $process_home" ;;
  esac
  process_homes="$process_homes|$process_home"
  case "$process_home" in
    "$snapshot"/*) fail "Neovim HOME is inside the plugin snapshot" ;;
  esac
  [ "$process_config" != "$process_data" ] || fail 'Neovim config and data homes must differ'
  [ "$process_state" != "$process_cache" ] || fail 'Neovim state and cache homes must differ'
  [ "$process_tmp" = "$process_root/tmp" ] || fail "Neovim TMPDIR is not process-isolated: $process_tmp"
done <"$nvim_log"
assert_no_caller_xdg_writes "$caller_root"
assert_removed_mktemp_roots
find "$lazy_root/lazy.nvim" "$lazy_root/LazyVim" "$lazy_root/snacks.nvim" -type f -exec shasum {} \; >"$source_hashes_after"
cmp "$source_hashes_before" "$source_hashes_after" >/dev/null || fail 'runner modified the real lazy plugin source'

failing_lua_test="$work_dir/failing-lua-test.lua"
printf 'error("intentional check runner Lua test failure")\n' >"$failing_lua_test"
failure_lua_output="$work_dir/failure-lua.out"
if (
  cd "$outside_dir"
  PATH="$wrapper_dir:$external_bin:$PATH" \
    CHECK_RUNNER_REAL_GIT="$real_git" \
    CHECK_RUNNER_REAL_NVIM="$real_nvim" \
    CHECK_RUNNER_SOURCE_LAZY_ROOT="$lazy_root" \
    CHECK_RUNNER_MKTEMP_LOG="$mktemp_log" \
    CHECK_RUNNER_NVIM_LOG="$nvim_log" \
    CHECK_RUNNER_FAIL_FIRST_LUA_TEST=1 \
    CHECK_RUNNER_FAILING_LUA_TEST="$failing_lua_test" \
    HOME="$caller_root/home" \
    XDG_CONFIG_HOME="$caller_root/config" \
    XDG_DATA_HOME="$caller_root/data" \
    XDG_STATE_HOME="$caller_root/state" \
    XDG_CACHE_HOME="$caller_root/cache" \
    NVIM_TEST_LAZY_ROOT="$relative_lazy_root" \
    check.sh
) >"$failure_lua_output" 2>&1; then
  fail 'runner must return non-zero when a real Lua test fails'
fi

assert_contains "$failure_lua_output" 'CHECK: tests/mkdp_spec.lua'
assert_contains "$failure_lua_output" 'intentional check runner Lua test failure'
assert_contains "$failure_lua_output" 'FAIL: tests/mkdp_spec.lua'
assert_no_caller_xdg_writes "$caller_root"
assert_removed_mktemp_roots

cat >"$wrapper_dir/nvim" <<'EOF'
#!/bin/sh
printf 'nvim failure wrapper invoked\n' >&2
exit 73
EOF
chmod +x "$wrapper_dir/nvim"

failure_output="$work_dir/failure.out"
if (
  cd "$outside_dir"
  PATH="$wrapper_dir:$PATH" \
    CHECK_RUNNER_REAL_GIT="$real_git" \
    CHECK_RUNNER_MKTEMP_LOG="$mktemp_log" \
    HOME="$caller_root/home" \
    XDG_CONFIG_HOME="$caller_root/config" \
    XDG_DATA_HOME="$caller_root/data" \
    XDG_STATE_HOME="$caller_root/state" \
    XDG_CACHE_HOME="$caller_root/cache" \
    NVIM_TEST_LAZY_ROOT="$relative_lazy_root" \
    "$runner"
) >"$failure_output" 2>&1; then
  fail 'runner must return non-zero when its first Neovim phase fails'
fi

assert_contains "$failure_output" 'Lua syntax'
assert_contains "$failure_output" 'nvim failure wrapper invoked'
assert_contains "$failure_output" 'FAIL: Lua syntax'
assert_no_caller_xdg_writes "$caller_root"
assert_removed_mktemp_roots

dependency_bin="$work_dir/dependency-bin"
mkdir -p "$dependency_bin"
for command_name in git nvim node python3 rm mkdir ln cp chmod find cat readlink; do
  ln -s "$(command -v "$command_name")" "$dependency_bin/$command_name"
done
missing_dependency_output="$work_dir/missing-dependency.out"
if PATH="$dependency_bin" /bin/bash "$runner" >"$missing_dependency_output" 2>&1; then
  fail 'runner must return non-zero when mktemp is unavailable'
fi
assert_contains "$missing_dependency_output" 'ERROR: required command not found: mktemp'
assert_contains "$missing_dependency_output" 'FAIL: dependency check'

complete_dependency_bin="$work_dir/complete-dependency-bin"
mkdir -p "$complete_dependency_bin"
for command_name in git nvim node python3 rm mkdir ln cp chmod find cat mktemp readlink; do
  ln -s "$(command -v "$command_name")" "$complete_dependency_bin/$command_name"
done
missing_node_bin="$work_dir/missing-node-bin"
mkdir -p "$missing_node_bin"
for command_name in git nvim python3 rm mkdir ln cp chmod find cat mktemp readlink; do
  ln -s "$(command -v "$command_name")" "$missing_node_bin/$command_name"
done
missing_node_output="$work_dir/missing-node.out"
if PATH="$missing_node_bin" /bin/bash "$runner" >"$missing_node_output" 2>&1; then
  fail 'runner must return non-zero when node is unavailable'
fi
assert_contains "$missing_node_output" 'ERROR: required command not found: node'
assert_contains "$missing_node_output" 'FAIL: dependency check'

missing_home_output="$work_dir/missing-home.out"
if HOME= XDG_DATA_HOME= NVIM_TEST_LAZY_ROOT= PATH="$complete_dependency_bin" /bin/bash "$runner" >"$missing_home_output" 2>&1; then
  fail 'runner must return non-zero without HOME, XDG_DATA_HOME, or NVIM_TEST_LAZY_ROOT'
fi
assert_contains "$missing_home_output" 'ERROR: set NVIM_TEST_LAZY_ROOT, XDG_DATA_HOME, or HOME'
assert_contains "$missing_home_output" 'FAIL: dependency check'

printf 'OK check runner uses isolated read-only plugin snapshots and propagates failures\n'
