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
