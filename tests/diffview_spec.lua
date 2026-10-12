-- Run through scripts/check.sh; replace only the Git and picker UI boundaries.
local spec = dofile("lua/plugins/diffview.lua")
local compare
for _, key in ipairs(spec.keys) do
  if key[1] == "<leader>DC" then
    compare = key[2]
  end
end
assert(type(compare) == "function", "commit comparison shortcut is missing")

local cwd = vim.fn.getcwd()
local commits = { "bbbbbbb 2026-10-12 新提交", "aaaaaaa 2026-10-11 旧提交" }
local pickers, opened, notices = {}, {}, {}
local git_error = 0
local original_systemlist, original_cmd, original_notify = vim.fn.systemlist, vim.cmd, vim.notify
local original_v, original_fzf = vim.v, package.loaded["fzf-lua"]
vim.v = setmetatable({ shell_error = 0 }, { __index = vim.v })
vim.fn.systemlist = function(args)
  assert(vim.deep_equal(args, { "git", "-C", cwd, "log", "--format=%h %ad %s", "--date=short", "HEAD" }))
  vim.v.shell_error = git_error
  return commits
end
package.loaded["fzf-lua"] = {
  fzf_exec = function(items, opts)
    assert(vim.deep_equal(items, commits), "picker must use the current branch history")
    pickers[#pickers + 1] = opts
  end,
}
vim.cmd = function(command)
  opened[#opened + 1] = command
end
vim.notify = function(message)
  notices[#notices + 1] = message
end

local function start()
  pickers, opened, notices = {}, {}, {}
  compare()
end

local function select(index, selection)
  pickers[index].actions.default(selection)
  vim.wait(20, function()
    return #pickers > index
  end)
end

start()
select(1, { commits[2] })
assert(#pickers == 2, "selecting the base commit must open a second picker")
select(2, { commits[1] })
assert(
  vim.deep_equal(opened, { "DiffviewOpen aaaaaaa..bbbbbbb -C=" .. vim.fn.fnameescape(cwd) }),
  "comparison must preserve selection order and target the same repository"
)

start()
select(1, {})
assert(#pickers == 1 and #opened == 0, "cancelling the first picker must stop")
start()
select(1, { commits[2] })
select(2, {})
assert(#opened == 0, "cancelling the second picker must stop")
start()
select(1, { commits[1] })
select(2, { commits[1] })
assert(#opened == 0 and #notices == 1, "the same commit must not open an empty comparison")

git_error = 128
start()
assert(#pickers == 0 and #notices == 1, "failed Git queries must report an error without opening fzf")
git_error = 0
commits = {}
start()
assert(#pickers == 0 and #notices == 1, "empty history must not open fzf")
vim.fn.systemlist, vim.cmd, vim.notify = original_systemlist, original_cmd, original_notify
vim.v, package.loaded["fzf-lua"] = original_v, original_fzf
print("OK Diffview commit selection, comparison, cancellation and Git errors")
