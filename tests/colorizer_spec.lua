-- Run through scripts/check.sh. This test validates the production Colorizer
-- spec without loading the external plugin.

local repo = vim.env.NVIM_CHECK_REPO or vim.fn.getcwd()
local spec = dofile(repo .. "/lua/plugins/nvim-colorizer.lua")

local expected_filetypes = {
  "css",
  "scss",
  "sass",
  "less",
  "html",
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "vue",
  "svelte",
  "astro",
}

local expected_commands = {
  "ColorizerAttachToBuffer",
  "ColorizerDetachFromBuffer",
  "ColorizerReloadAllBuffers",
  "ColorizerToggle",
}

local function eq(actual, expected, message)
  assert(
    vim.deep_equal(actual, expected),
    string.format("%s\nexpected: %s\nactual:   %s", message, vim.inspect(expected), vim.inspect(actual))
  )
end

assert(spec[1] == "catgoose/nvim-colorizer.lua", "must keep the configured Colorizer plugin")
assert(spec.event == nil, "Colorizer must not use a broad event trigger")
eq(spec.ft, expected_filetypes, "lazy filetypes must match the approved automatic scope")
eq(spec.opts.filetypes, expected_filetypes, "Colorizer filetypes must match the approved automatic scope")
assert(spec.ft == spec.opts.filetypes, "lazy and Colorizer filetypes must reuse the same table")
eq(spec.cmd, expected_commands, "manual Colorizer commands must remain lazy-load entry points")
assert(not vim.tbl_contains(spec.ft, "*"), "automatic filetypes must not contain wildcard")
for _, excluded in ipairs({ "bigfile", "lua", "markdown", "help", "log", "terminal" }) do
  assert(not vim.tbl_contains(spec.ft, excluded), excluded .. " must not auto-load Colorizer")
end
assert(vim.tbl_get(spec, "opts", "user_default_options", "css") == true, "full CSS parsing must remain enabled")

print("OK Colorizer uses precise filetypes and preserves manual commands")
