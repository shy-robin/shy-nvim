#!/usr/bin/env bash
# Run the repository's read-only local validation suite from any working directory.
set -euo pipefail

stage='dependency check'
temp_root=''
rm_bin=''
chmod_bin=''

on_exit() {
  exit_code=$?
  if [ -n "$temp_root" ] && [ -e "$temp_root" ]; then
    if [ -n "$chmod_bin" ]; then
      "$chmod_bin" -R u+w "$temp_root" || exit_code=1
    fi
    if [ -n "$rm_bin" ]; then
      "$rm_bin" -rf "$temp_root" || exit_code=1
    else
      printf 'ERROR: cannot clean temporary directory because rm is unavailable\n' >&2
      exit_code=1
    fi
  fi
  if [ "$exit_code" -eq 0 ]; then
    printf '\nSUCCESS: all local validation stages passed; temporary XDG removed\n'
  else
    printf 'FAIL: %s (exit %s; temporary XDG removed)\n' "$stage" "$exit_code" >&2
  fi
  trap - EXIT
  exit "$exit_code"
}
trap on_exit EXIT

require_command() {
  command_name=$1
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'ERROR: required command not found: %s\n' "$command_name" >&2
    exit 127
  fi
}

run_stage() {
  stage=$1
  shift
  printf '\nCHECK: %s\n' "$stage"
  "$@"
}

run_nvim() {
  process_root=$("$mktemp_bin" -d "$temp_root/process.XXXXXX")
  process_home=$process_root/home
  process_config=$process_root/config
  process_data=$process_root/data
  process_state=$process_root/state
  process_cache=$process_root/cache
  process_tmp=$process_root/tmp
  "$mkdir_bin" -p "$process_home" "$process_config" "$process_data/nvim" "$process_state" "$process_cache" "$process_tmp"
  "$ln_bin" -s "$plugin_snapshot" "$process_data/nvim/lazy"
  HOME="$process_home" \
    XDG_CONFIG_HOME="$process_config" \
    XDG_DATA_HOME="$process_data" \
    XDG_STATE_HOME="$process_state" \
    XDG_CACHE_HOME="$process_cache" \
    TMPDIR="$process_tmp" \
    NVIM_TEST_LAZY_ROOT="$plugin_snapshot" \
    NVIM_CHECK_REPO="$repo_dir" \
    PATH="$blocked_bin:$PATH" \
    "$nvim_bin" "$@"
}

run_nvim_lua_test() {
  test_file=$1
  (
    cd "$repo_dir"
    NVIM_CHECK_LUA_TEST="$test_file" \
      NVIM_CHECK_LUA_TEST_LOADER="$lua_test_loader" \
      run_nvim --headless -u NORC --cmd 'lua dofile(vim.env.NVIM_CHECK_LUA_TEST_LOADER)'
  )
}

check_lua_syntax() {
  syntax_loader="$temp_root/check-lua-syntax.lua"
  "$cat_bin" >"$syntax_loader" <<'LUA'
for _, path in ipairs(vim.fn.argv()) do
  local chunk, err = loadfile(path)
  assert(chunk, string.format("Lua syntax error in %s:\n%s", path, err))
end
print("OK Lua syntax")
vim.cmd("qa!")
LUA
  export NVIM_CHECK_LUA_LOADER="$syntax_loader"

  lua_files=()
  while IFS= read -r -d '' path; do
    lua_files+=("$path")
  done < <("$find_bin" "$repo_dir/init.lua" "$repo_dir/lua" "$repo_dir/tests" -type f -name '*.lua' -print0)
  [ "${#lua_files[@]}" -gt 0 ] || {
    printf 'ERROR: no Lua files found for syntax checking\n' >&2
    return 1
  }
  run_nvim --headless -u NORC --cmd 'lua dofile(vim.env.NVIM_CHECK_LUA_LOADER)' "${lua_files[@]}"
}

check_json() {
  "$git_bin" -C "$repo_dir" ls-files -co --exclude-standard -z -- '*.json' |
    REPO_DIR="$repo_dir" "$python_bin" -c '
import json
import os
import sys

repo = os.environ["REPO_DIR"]
paths = [item.decode("utf-8") for item in sys.stdin.buffer.read().split(b"\0") if item]
if not paths:
    raise SystemExit("no repository JSON files found")
errors = []
for relative_path in paths:
    path = os.path.join(repo, relative_path)
    try:
        with open(path, "r", encoding="utf-8") as source:
            json.load(source)
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        errors.append("{}: {}".format(relative_path, error))
if errors:
    raise SystemExit("JSON parse failed:\n" + "\n".join(errors))
print("OK JSON parsing ({} files)".format(len(paths)))
'
}

check_minimal_startup() {
  run_nvim --headless -u "$repo_dir/tests/minimal_init.lua" +qa
}

for command_name in git nvim node python3 rm mkdir ln cp chmod find cat mktemp readlink; do
  require_command "$command_name"
done

git_bin=$(command -v git)
nvim_bin=$(command -v nvim)
node_bin=$(command -v node)
python_bin=$(command -v python3)
rm_bin=$(command -v rm)
mkdir_bin=$(command -v mkdir)
ln_bin=$(command -v ln)
cp_bin=$(command -v cp)
chmod_bin=$(command -v chmod)
find_bin=$(command -v find)
cat_bin=$(command -v cat)
mktemp_bin=$(command -v mktemp)
readlink_bin=$(command -v readlink)

script_path=${BASH_SOURCE[0]}
case "$script_path" in
  /*) ;;
  */*) script_path=$PWD/$script_path ;;
  *)
    resolved_script_path=$(command -v "$script_path" || true)
    if [ -z "$resolved_script_path" ]; then
      printf 'ERROR: cannot locate check script on PATH: %s\n' "$script_path" >&2
      exit 1
    fi
    case "$resolved_script_path" in
      /*) script_path=$resolved_script_path ;;
      *) script_path=$PWD/$resolved_script_path ;;
    esac
    ;;
esac
while [ -L "$script_path" ]; do
  link_target=$("$readlink_bin" "$script_path")
  case "$link_target" in
    /*) script_path=$link_target ;;
    *) script_path=${script_path%/*}/$link_target ;;
  esac
done
script_dir=${script_path%/*}
repo_dir=$(cd "$script_dir/.." && pwd -P)

requested_lazy_root=${NVIM_TEST_LAZY_ROOT:-}
if [ -n "$requested_lazy_root" ]; then
  lazy_root=$requested_lazy_root
elif [ -n "${XDG_DATA_HOME:-}" ]; then
  lazy_root=$XDG_DATA_HOME/nvim/lazy
elif [ -n "${HOME:-}" ]; then
  lazy_root=$HOME/.local/share/nvim/lazy
else
  printf 'ERROR: set NVIM_TEST_LAZY_ROOT, XDG_DATA_HOME, or HOME to locate installed Lazy plugins\n' >&2
  exit 1
fi
case "$lazy_root" in
  /*) ;;
  *) lazy_root=$PWD/$lazy_root ;;
esac
if [ ! -d "$lazy_root" ]; then
  printf 'ERROR: NVIM_TEST_LAZY_ROOT does not exist: %s\n' "$lazy_root" >&2
  exit 1
fi
lazy_root=$(cd "$lazy_root" && pwd -P)
for plugin_name in lazy.nvim LazyVim snacks.nvim; do
  if [ ! -d "$lazy_root/$plugin_name" ]; then
    printf 'ERROR: NVIM_TEST_LAZY_ROOT must contain %s: %s\n' "$plugin_name" "$lazy_root" >&2
    exit 1
  fi
done

temp_root=$("$mktemp_bin" -d "${TMPDIR:-/tmp}/nvim-check.XXXXXX")
plugin_snapshot=$temp_root/plugins
blocked_bin=$temp_root/blocked-bin
"$mkdir_bin" -p "$plugin_snapshot" "$blocked_bin"
for plugin_name in lazy.nvim LazyVim snacks.nvim; do
  "$cp_bin" -R "$lazy_root/$plugin_name" "$plugin_snapshot/$plugin_name"
done
"$chmod_bin" -R a-w "$plugin_snapshot"
for blocked_command in git curl wget npx npm yarn; do
  "$cat_bin" >"$blocked_bin/$blocked_command" <<EOF
#!/bin/sh
printf 'blocked external command: %s\\n' "$blocked_command" >&2
exit 126
EOF
  "$chmod_bin" a+rx "$blocked_bin/$blocked_command"
done

lua_test_loader=$temp_root/run-nvim-lua-test.lua
"$cat_bin" >"$lua_test_loader" <<'LUA'
local test_file = vim.env.NVIM_CHECK_LUA_TEST
local ok, err = xpcall(function()
  assert(test_file and test_file ~= "", "NVIM_CHECK_LUA_TEST must name a Lua test file")
  dofile(test_file)
end, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
LUA

run_stage 'Lua syntax' check_lua_syntax
run_stage 'JSON parsing' check_json
run_stage 'tests/mkdp_spec.lua' run_nvim_lua_test tests/mkdp_spec.lua
run_stage 'tests/mkdp_route_fix_test.js' "$node_bin" "$repo_dir/tests/mkdp_route_fix_test.js"
run_stage 'tests/lazygit_spec.lua' run_nvim_lua_test tests/lazygit_spec.lua
run_stage 'tests/spec_opts_spec.lua' run_nvim_lua_test tests/spec_opts_spec.lua
run_stage 'tests/migration_cleanup_spec.lua' run_nvim_lua_test tests/migration_cleanup_spec.lua
run_stage 'tests/documentation_spec.lua' run_nvim_lua_test tests/documentation_spec.lua
run_stage 'tests/bigfile_spec.lua' run_nvim_lua_test tests/bigfile_spec.lua
run_stage 'minimal headless startup' check_minimal_startup
