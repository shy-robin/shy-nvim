-- Run through scripts/check.sh. The runner supplies an isolated data/nvim/lazy
-- snapshot so this test can execute production config.lazy without its clone fallback.

local repo = vim.fn.getcwd()
local lazy_root = vim.env.NVIM_TEST_LAZY_ROOT
assert(lazy_root and lazy_root ~= "", "NVIM_TEST_LAZY_ROOT must point to the installed lazy plugin root")

for _, path in ipairs({ repo, lazy_root .. "/LazyVim", lazy_root .. "/lazy.nvim" }) do
  vim.opt.runtimepath:prepend(path)
end
assert(vim.uv.fs_stat(vim.fn.stdpath("data") .. "/lazy/lazy.nvim"), "temporary data must expose lazy.nvim")

local captured_opts
package.loaded.lazy = {
  setup = function(opts)
    captured_opts = opts
  end,
}
dofile(repo .. "/lua/config/lazy.lua")
assert(captured_opts, "production config.lazy must call lazy.setup")
package.loaded.lazy = nil

local Config = require("lazy.core.config")
Config.options = vim.tbl_deep_extend("force", vim.deepcopy(Config.defaults), captured_opts, {
  root = lazy_root,
  local_spec = false,
  pkg = { enabled = false },
})

local Plugin = require("lazy.core.plugin")
local spec = Plugin.Spec.new(nil, { pkg = false })
Config.spec = spec
spec:parse(captured_opts.spec)

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

local function has_trigger(plugin, property, value)
  local triggers = Plugin.values(plugin, property, false)
  if type(triggers) == "string" then
    return triggers == value
  end
  return contains(triggers, value)
end

local function has_key(plugin, lhs)
  local keys = Plugin.values(plugin, "keys", false)
  for _, key in ipairs(keys or {}) do
    if key[1] == lhs then
      return true
    end
  end
  return false
end

local function has_dependency(plugin, name)
  return contains(Plugin.values(plugin, "dependencies", false), name)
end

local precise_plugins = {
  ["orgmode"] = { ft = "org", cmd = "Org", keys = { "<Leader>Oa", "<Leader>Oc" } },
  ["leetcode.nvim"] = { cmd = "Leet" },
  ["markdown-preview.nvim"] = { ft = "markdown", cmd = "MarkdownPreviewToggle", keys = { "gom", "goM" } },
  ["vim-floaterm"] = { cmd = "FloatermKill", keys = { "<C-o>" } },
  ["comment-box.nvim"] = { keys = { "<leader>cbb" } },
  ["img-clip.nvim"] = { keys = { "<leader>pi" } },
  ["translate.nvim"] = { cmd = "Translate", keys = { "<leader>tz", "<leader>te" } },
  ["nvim-picgo"] = { keys = { "<leader>pp", "<leader>pP" } },
  ["nvim-tree.lua"] = { keys = { "<leader>e" } },
}

for name, expected in pairs(precise_plugins) do
  local plugin = assert(spec.plugins[name], "missing plugin in merged spec: " .. name)
  check(name, plugin.event == nil, "must not load on VeryLazy or another broad event")
  if expected.ft then
    check(name, has_trigger(plugin, "ft", expected.ft), "is missing filetype trigger " .. expected.ft)
  end
  if expected.cmd then
    check(name, has_trigger(plugin, "cmd", expected.cmd), "is missing command trigger " .. expected.cmd)
  end
  for _, lhs in ipairs(expected.keys or {}) do
    check(name, has_key(plugin, lhs), "is missing key trigger " .. lhs)
  end
end

local leetcode = assert(spec.plugins["leetcode.nvim"], "missing leetcode.nvim plugin spec")
check("leetcode.nvim", has_dependency(leetcode, "fzf-lua"), "must use the existing fzf-lua picker")
check("leetcode.nvim", not has_dependency(leetcode, "nvim-telescope/telescope.nvim"), "must not retain Telescope")
check("scope.nvim", spec.plugins["scope.nvim"] == nil, "must be removed because it has no reachable trigger")

local directory_startup_ok, directory_startup = pcall(require, "config.directory_startup")
check("nvim-tree.lua", directory_startup_ok, "directory-only startup helper is missing")
if directory_startup_ok then
  check(
    "nvim-tree.lua",
    type(directory_startup.startup_action) == "function",
    "directory startup helper must schedule opening after VimEnter has already run"
  )
  if type(directory_startup.startup_action) == "function" then
    check(
      "nvim-tree.lua",
      directory_startup.startup_action(0) == "VimEnter",
      "must wait for VimEnter before startup has completed"
    )
    check(
      "nvim-tree.lua",
      directory_startup.startup_action(1) == "schedule",
      "must schedule opening when lazy initialization runs after VimEnter"
    )
  end
  check("nvim-tree.lua", directory_startup.directory_argument({}, function()
    return { type = "directory" }
  end) == nil, "must not load nvim-tree with no startup argument")
  check("nvim-tree.lua", directory_startup.directory_argument({ "/tmp/file" }, function()
    return { type = "file" }
  end) == nil, "must not load nvim-tree for an ordinary file argument")
  check("nvim-tree.lua", directory_startup.directory_argument({ "/tmp/project" }, function()
    return { type = "directory" }
  end) == "/tmp/project", "must load nvim-tree for exactly one directory argument")
end

if #failures > 0 then
  error("merged plugin opts assertions failed:\n- " .. table.concat(failures, "\n- "))
end

print("OK merged nvim-lspconfig, conform.nvim, mason.nvim, and precise lazy triggers")
