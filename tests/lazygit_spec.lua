-- 运行：nvim --headless -u NORC +"luafile tests/lazygit_spec.lua" +qa
-- 必须在仓库根目录执行。
local before = vim.fn.maparg("<C-c>", "t", false, true)
local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/lazygit.lua")

if spec.config ~= nil then
  assert(type(spec.config) == "function", "LazyGit config must be a function when present")
  spec.config()
end

local after = vim.fn.maparg("<C-c>", "t", false, true)
assert(
  vim.deep_equal(after, before),
  string.format(
    "LazyGit spec/config must not add a global terminal <C-c> mapping: before=%s, after=%s",
    vim.inspect(before),
    vim.inspect(after)
  )
)

print("OK lazygit preserves global terminal <C-c>")
