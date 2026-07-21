-- Run with Bash from the repository root without touching the user's XDG state:
-- bash -c 'tmp=$(mktemp -d); XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" \
-- XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache" \
-- NVIM_TEST_LAZY_ROOT="$HOME/.local/share/nvim/lazy" \
-- nvim --headless -u NORC +"luafile tests/spec_opts_spec.lua" +qa; code=$?; rm -rf "$tmp"; exit $code'

local repo = vim.fn.getcwd()
local lazy_root = vim.env.NVIM_TEST_LAZY_ROOT
assert(lazy_root and lazy_root ~= "", "NVIM_TEST_LAZY_ROOT must point to the installed lazy plugin root")

for _, path in ipairs({ repo, lazy_root .. "/LazyVim", lazy_root .. "/lazy.nvim" }) do
  vim.opt.runtimepath:prepend(path)
end

local Config = require("lazy.core.config")
Config.options = vim.tbl_deep_extend("force", vim.deepcopy(Config.defaults), {
  root = lazy_root,
  local_spec = false,
  pkg = { enabled = false },
})

local Plugin = require("lazy.core.plugin")
local spec = Plugin.Spec.new(nil, { pkg = false })
Config.spec = spec
-- Keep this import graph synchronized with lua/config/lazy.lua.
spec:parse({
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  { import = "lazyvim.plugins.extras.coding.blink" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.markdown" },
  { import = "lazyvim.plugins.extras.lang.go" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.sql" },
  { import = "lazyvim.plugins.extras.lang.svelte" },
  { import = "lazyvim.plugins.extras.lang.vue" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.coding.neogen" },
  { import = "lazyvim.plugins.extras.util.rest" },
  { import = "lazyvim.plugins.extras.editor.outline" },
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "plugins" },
})

local load_errors = {}
for _, notif in ipairs(spec.notifs) do
  if notif.level >= vim.log.levels.ERROR then
    load_errors[#load_errors + 1] = notif.msg
  end
end
assert(#load_errors == 0, "failed to load real plugin specs:\n" .. table.concat(load_errors, "\n"))

Config.plugins = spec.plugins

local function final_opts(name)
  local plugin = assert(spec.plugins[name], "missing plugin in merged spec: " .. name)
  return Plugin.values(plugin, "opts", false)
end

local failures = {}
local function check(group, condition, message)
  if not condition then
    failures[#failures + 1] = string.format("%s: %s", group, message)
  end
end

local function contains(list, value)
  return type(list) == "table" and vim.tbl_contains(list, value)
end

local lsp = final_opts("nvim-lspconfig")
local vtsls = vim.tbl_get(lsp, "servers", "vtsls")
check("nvim-lspconfig", type(vtsls) == "table" and vtsls.enabled ~= false, "vtsls is missing or disabled")
for _, server_name in ipairs({ "ts_ls", "tsgo" }) do
  local server = vim.tbl_get(lsp, "servers", server_name)
  check(
    "nvim-lspconfig",
    server == nil or server.enabled == false,
    server_name .. " must be absent or explicitly disabled while vtsls is active"
  )
end
check(
  "nvim-lspconfig",
  vim.tbl_get(lsp, "servers", "vtsls", "settings", "typescript", "inlayHints", "parameterNames", "enabled") == "all",
  "vtsls is missing the repository TypeScript inlay hint settings"
)
check(
  "nvim-lspconfig",
  vim.tbl_get(lsp, "servers", "vtsls", "settings", "javascript", "inlayHints", "functionLikeReturnTypes", "enabled")
    == true,
  "vtsls is missing the repository JavaScript inlay hint settings"
)
check(
  "nvim-lspconfig",
  vim.tbl_get(lsp, "servers", "vtsls", "settings", "typescript", "preferences") == nil,
  "vtsls still contains legacy TypeScript preference keys"
)
check(
  "nvim-lspconfig",
  vim.tbl_get(lsp, "servers", "lua_ls", "settings", "Lua", "workspace", "checkThirdParty") == false,
  "lua_ls is missing the repository workspace setting"
)
check(
  "nvim-lspconfig",
  vim.tbl_get(lsp, "servers", "pyright", "settings", "python", "analysis", "diagnosticMode") == "openFilesOnly",
  "pyright is missing the repository analysis setting"
)
check(
  "nvim-lspconfig",
  vim.tbl_get(lsp, "servers", "gopls", "settings", "gopls", "gofumpt") == true,
  "gopls is missing the repository settings"
)
for _, analyzer in ipairs({ "fieldalignment", "useany" }) do
  check(
    "nvim-lspconfig",
    vim.tbl_get(lsp, "servers", "gopls", "settings", "gopls", "analyses", analyzer) == nil,
    "gopls still enables the removed " .. analyzer .. " analyzer"
  )
end
check(
  "nvim-lspconfig",
  type(vim.tbl_get(lsp, "servers", "vue_ls")) == "table"
    and contains(vim.tbl_get(lsp, "servers", "vtsls", "filetypes"), "vue"),
  "LazyVim's vue_ls/vtsls hybrid configuration is missing"
)
check(
  "nvim-lspconfig",
  vim.tbl_get(lsp, "servers", "typescript_tools") == nil and vim.tbl_get(lsp, "servers", "volar") == nil,
  "deprecated/duplicate TypeScript or Vue servers remain configured"
)

local conform = final_opts("conform.nvim")
local python = vim.tbl_get(conform, "formatters_by_ft", "python")
check(
  "conform.nvim",
  type(python) == "table" and python[1] == "isort" and python[2] == "black" and python.stop_after_first == nil,
  "Python formatters must run isort then black without stop_after_first"
)
check(
  "conform.nvim",
  contains(vim.tbl_get(conform, "formatters_by_ft", "go"), "gofumpt")
    and contains(vim.tbl_get(conform, "formatters_by_ft", "go"), "goimports"),
  "Go formatter matrix is missing"
)
check(
  "conform.nvim",
  contains(vim.tbl_get(conform, "formatters_by_ft", "sql"), "sqlfmt"),
  "SQL formatter matrix is missing"
)
local prettierd_condition = vim.tbl_get(conform, "formatters", "prettierd", "condition")
check("conform.nvim", type(prettierd_condition) == "function", "prettierd project condition is missing")
local prettier_root = vim.fn.tempname()
local prettier_source = prettier_root .. "/src/example.ts"
vim.fn.mkdir(prettier_root .. "/src", "p")
vim.fn.writefile({}, prettier_root .. "/.prettierrc")
local condition_result = type(prettierd_condition) == "function"
  and prettierd_condition({}, { filename = prettier_source, dirname = prettier_root .. "/src" })
vim.fn.delete(prettier_root, "rf")
check(
  "conform.nvim",
  condition_result ~= nil and condition_result ~= false,
  "prettierd condition does not follow Conform's (config, ctx) callback signature"
)
check(
  "conform.nvim",
  contains(vim.tbl_get(conform, "formatters_by_ft", "http"), "kulala"),
  "existing HTTP formatter override was lost"
)

local mason = final_opts("mason.nvim")
local ensure_installed = mason.ensure_installed
local seen_packages = {}
local duplicate_packages = {}
for _, package in ipairs(ensure_installed) do
  if seen_packages[package] then
    duplicate_packages[#duplicate_packages + 1] = package
  end
  seen_packages[package] = true
end
check(
  "mason.nvim",
  #duplicate_packages == 0,
  "ensure_installed contains duplicates: " .. table.concat(duplicate_packages, ", ")
)
local expected_packages = {
  "stylua",
  "shfmt",
  "js-debug-adapter",
  "markdownlint-cli2",
  "markdown-toc",
  "goimports",
  "gofumpt",
  "golangci-lint",
  "delve",
  "sqlfluff",
  "prettier",
  "vtsls",
  "vue-language-server",
  "lua-language-server",
  "json-lsp",
  "yaml-language-server",
  "html-lsp",
  "css-lsp",
  "svelte-language-server",
  "pyright",
  "ruff",
  "gopls",
  "rust-analyzer",
  "tailwindcss-language-server",
  "emmet-language-server",
  "prettierd",
  "black",
  "isort",
  "sqlfmt",
  "kulala-fmt",
  "eslint_d",
  "shellcheck",
  "hadolint",
  "debugpy",
  "codelldb",
}
local expected_package_set = {}
local missing_packages = {}
for _, package in ipairs(expected_packages) do
  expected_package_set[package] = true
  if not seen_packages[package] then
    missing_packages[#missing_packages + 1] = package
  end
end
local unexpected_packages = {}
for _, package in ipairs(ensure_installed) do
  if not expected_package_set[package] then
    unexpected_packages[#unexpected_packages + 1] = package
  end
end
check(
  "mason.nvim",
  #missing_packages == 0 and #unexpected_packages == 0,
  "ensure_installed mismatch; missing: "
    .. table.concat(missing_packages, ", ")
    .. "; unexpected: "
    .. table.concat(unexpected_packages, ", ")
)
for _, package in ipairs({ "typescript-tools", "rustfmt", "fish_indent" }) do
  check("mason.nvim", not contains(ensure_installed, package), "ensure_installed contains invalid package " .. package)
end
check(
  "mason.nvim",
  vim.tbl_get(mason, "ui", "border") == "rounded" and vim.tbl_get(mason, "ui", "backdrop") == 100,
  "Mason UI settings were not preserved"
)

if #failures > 0 then
  error("merged plugin opts assertions failed:\n- " .. table.concat(failures, "\n- "))
end

print("OK merged nvim-lspconfig, conform.nvim, and mason.nvim opts")
