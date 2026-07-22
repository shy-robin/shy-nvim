-- Minimal isolated startup check. It executes the production config.lazy entry point,
-- but replaces only lazy.setup with a capture function before that entry point runs.
-- This lets us parse the real production opts/spec without starting Lazy's checker,
-- installs, Mason, or any plugin setup.
local function check()
  local repo = assert(vim.env.NVIM_CHECK_REPO, "NVIM_CHECK_REPO must point to the repository")
  local lazy_root = assert(vim.env.NVIM_TEST_LAZY_ROOT, "NVIM_TEST_LAZY_ROOT must point to the plugin snapshot")
  local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

  assert(vim.uv.fs_stat(lazy_path), "temporary data must expose lazy.nvim")
  vim.opt.runtimepath:prepend(repo)
  package.path = repo .. "/lua/?.lua;" .. repo .. "/lua/?/init.lua;" .. package.path
  dofile(repo .. "/lua/config/options.lua")

  local captured_opts
  package.loaded.lazy = {
    setup = function(opts)
      captured_opts = opts
    end,
  }
  dofile(repo .. "/lua/config/lazy.lua")
  assert(captured_opts, "production config.lazy must call lazy.setup")
  assert(captured_opts.checker and captured_opts.checker.enabled == true, "captured production checker setting is missing")

  -- Now load lazy.core from the snapshot. No call to the real lazy.setup is made.
  vim.opt.runtimepath:prepend(lazy_root .. "/LazyVim")
  vim.opt.runtimepath:prepend(lazy_root .. "/lazy.nvim")
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

  local errors = {}
  for _, notif in ipairs(spec.notifs) do
    if notif.level >= vim.log.levels.ERROR then
      errors[#errors + 1] = notif.msg
    end
  end
  assert(#errors == 0, "failed to load real plugin specs:\n" .. table.concat(errors, "\n"))
  assert(next(spec.plugins) ~= nil, "real plugin spec must not be empty")
end

local ok, err = xpcall(check, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
print("OK minimal isolated production config/spec startup")
