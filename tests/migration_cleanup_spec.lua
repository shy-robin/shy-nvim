-- Run through scripts/check.sh. Active Lua configuration and TODO must not retain
-- references to removed completion, terminal, or AI integrations.

local repo = vim.env.NVIM_CHECK_REPO or vim.fn.getcwd()
local failures = {}

local function check(condition, message)
  if not condition then
    failures[#failures + 1] = message
  end
end

local function read(relative_path)
  local path = repo .. "/" .. relative_path
  local ok, lines = pcall(vim.fn.readfile, path)
  check(ok, "cannot read " .. relative_path)
  return ok and table.concat(lines, "\n") or ""
end

local removed_terms = {
  "coc",
  "llmapphandler",
  "llm.nvim",
  "opencode",
  "toggleterm",
  "avante",
}

local active_files = vim.fn.globpath(repo .. "/lua", "**/*.lua", false, true)
table.insert(active_files, repo .. "/TODO.md")
for _, path in ipairs(active_files) do
  local relative_path = path:sub(#repo + 2)
  local content = read(relative_path):lower()
  for _, term in ipairs(removed_terms) do
    check(not content:find(term, 1, true), relative_path .. " still references removed integration " .. term)
  end
end

check(vim.uv.fs_stat(repo .. "/.migration_backup") == nil, ".migration_backup must be removed")

local required_stack = {
  ["lua/plugins/supermaven.lua"] = "supermaven-inc/supermaven-nvim",
  ["lua/plugins/vim-floaterm.lua"] = "voldikss/vim-floaterm",
  ["lua/plugins/lsp.lua"] = "neovim/nvim-lspconfig",
  ["lua/plugins/blink.lua"] = "saghen/blink.cmp",
  ["lua/plugins/fzf.lua"] = "ibhagwan/fzf-lua",
}
for path, marker in pairs(required_stack) do
  check(read(path):find(marker, 1, true) ~= nil, path .. " must preserve " .. marker)
end

local keymaps = read("lua/config/keymaps.lua")
check(keymaps:find("FloatermKill!", 1, true) ~= nil, "quit mapping must preserve Floaterm cleanup")
check(keymaps:find('require("supermaven-nvim.api")', 1, true) ~= nil, "Supermaven toggle must be preserved")

if #failures > 0 then
  error("migration cleanup assertions failed:\n- " .. table.concat(failures, "\n- "))
end

print("OK migration remnants removed while current stack is preserved")
