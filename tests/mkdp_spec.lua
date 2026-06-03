-- 运行：nvim --headless -u NORC +"luafile tests/mkdp_spec.lua" +qa
-- 必须在仓库根目录执行。
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local M = require("util.mkdp")

local function eq(actual, expected, msg)
  assert(actual == expected,
    string.format("%s: expected %s, got %s", msg, vim.inspect(expected), vim.inspect(actual)))
end

eq(M.bufnr_from_url("http://localhost:8090/page/3"), 3, "localhost host")
eq(M.bufnr_from_url("http://127.0.0.1:8080/page/12"), 12, "ip host")
eq(M.bufnr_from_url("http://localhost:8090/"), nil, "no page segment")
eq(M.bufnr_from_url(nil), nil, "nil input")

print("OK mkdp bufnr_from_url")
