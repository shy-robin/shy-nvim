-- Run through scripts/check.sh. No external command is executed.
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local deps = require("util.dependencies")

local function eq(actual, expected, message)
  assert(
    vim.deep_equal(actual, expected),
    string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual))
  )
end

local function with_value(object, key, value, callback)
  local original = object[key]
  object[key] = value
  local ok, err = xpcall(callback, debug.traceback)
  object[key] = original
  assert(ok, err)
end

local function with_executables(available, callback)
  with_value(vim.fn, "executable", function(command)
    return available[command] and 1 or 0
  end, callback)
end

local function with_has(values, callback)
  with_value(vim.fn, "has", function(feature)
    return values[feature] and 1 or 0
  end, callback)
end

-- 版本比较
eq(deps.version_compare("1.2.3", "1.2.3"), 0, "equal versions")
eq(deps.version_compare("1.2.3", "1.2.4"), -1, "lower version")
eq(deps.version_compare("2.0.0", "1.9.9"), 1, "higher version")
eq(deps.version_compare("16.18.0", "16.18"), 0, "missing patch treated as zero")

-- 注册表结构
assert(#deps.registry > 0, "registry must not be empty")
local ids = {}
for _, dep in ipairs(deps.registry) do
  assert(type(dep.id) == "string" and dep.id ~= "", "dep must have id")
  assert(not ids[dep.id], "duplicate dep id: " .. dep.id)
  ids[dep.id] = true
  assert(type(dep.name) == "string" and dep.name ~= "", "dep must have name: " .. dep.id)
  assert(type(dep.commands) == "table" and #dep.commands > 0, "dep must have commands: " .. dep.id)
  assert(type(dep.required) == "boolean", "dep required must be boolean: " .. dep.id)
  assert(type(dep.category) == "string" and dep.category ~= "", "dep must have category: " .. dep.id)
end

-- 单项检查：缺失
with_executables({}, function()
  local r = deps.check_one(deps.registry[1])
  assert(r.missing == true, "missing dep should be missing")
  assert(r.installed == false, "missing dep should not be installed")
end)

-- 单项检查：已安装（无版本要求）
with_executables({ sh = true }, function()
  local sh_dep
  for _, dep in ipairs(deps.registry) do
    if dep.id == "sh" then
      sh_dep = dep
    end
  end
  local r = deps.check_one(sh_dep)
  assert(r.installed == true, "sh should be installed")
  assert(r.missing == false, "sh should not be missing")
end)

-- any 模式：任一命令存在即可
with_executables({ identify = true }, function()
  local image_dep
  for _, dep in ipairs(deps.registry) do
    if dep.id == "image_tool" then
      image_dep = dep
    end
  end
  local r = deps.check_one(image_dep)
  assert(r.installed == true, "image_tool should be installed via identify")
end)

-- 安装命令解析
with_has({ mac = true }, function()
  with_executables({ brew = true }, function()
    local git_dep
    for _, dep in ipairs(deps.registry) do
      if dep.id == "git" then
        git_dep = dep
      end
    end
    local cmd = deps.install_command(git_dep, "brew")
    assert(cmd == "brew install git", "brew install command mismatch")
  end)
end)

-- 包管理器检测：macOS
with_has({ mac = true }, function()
  with_executables({ brew = true }, function()
    eq(deps.detect_package_manager(), "brew", "macOS detects brew")
  end)
end)

-- 包管理器检测：Linux apt
with_has({}, function()
  with_executables({ ["apt-get"] = true }, function()
    eq(deps.detect_package_manager(), "apt", "Linux detects apt")
  end)
end)

-- 状态持久化
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
local state_file = tmp .. "/deps.json"
vim.env.SHY_NVIM_DEPS_STATE = state_file

local state = deps.load_state()
eq(state.ignored, {}, "empty state has no ignored")
deps.set_ignored("rg", true)
local state2 = deps.load_state()
eq(state2.ignored.rg, true, "ignored state persists")
deps.set_ignored("rg", false)
local state3 = deps.load_state()
assert(state3.ignored.rg == nil, "unignore persists")

-- check_all 过滤已忽略的可选依赖
with_executables({}, function()
  deps.set_ignored("rg", true)
  local results = deps.check_all()
  for _, r in ipairs(results) do
    assert(r.dep.id ~= "rg", "ignored optional dep should be filtered")
  end
  local all_results = deps.check_all(true)
  local found = false
  for _, r in ipairs(all_results) do
    if r.dep.id == "rg" then
      found = true
      assert(r.ignored == true, "ignored dep should be marked ignored")
    end
  end
  assert(found, "ignored dep should appear when include_ignored is true")
  deps.set_ignored("rg", false)
end)

-- maybe_open 守卫：禁用标志
vim.g.shy_nvim_disable_deps_check = true
deps.maybe_open()
vim.g.shy_nvim_disable_deps_check = nil

-- 清理
vim.env.SHY_NVIM_DEPS_STATE = nil
vim.fn.delete(tmp, "rf")

print("OK dependency checker registry, checks, package manager, and state")
