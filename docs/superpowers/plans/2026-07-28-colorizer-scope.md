# Colorizer 精确加载与 bigfile 隔离实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 只在前端颜色相关文件中自动加载 Colorizer，并确保 bigfile 不保留 Colorizer 的持续扫描与滚动重绘回调。

**Architecture:** Colorizer plugin spec 使用一份共享文件类型白名单同时驱动 lazy.nvim `ft` 触发器和 Colorizer `opts.filetypes`，并保留四个命令触发器用于手动覆盖。Snacks bigfile setup 只通过 `package.loaded.colorizer` 检查并分离已附加 buffer，不允许大文件路径触发 Colorizer 加载。

**Tech Stack:** Neovim 0.11、LazyVim/lazy.nvim plugin spec、catgoose/nvim-colorizer.lua、Snacks bigfile、Lua headless tests、Bash checker、StyLua 2.0.2。

## Global Constraints

- 自动文件类型必须精确为：`css`、`scss`、`sass`、`less`、`html`、`javascript`、`javascriptreact`、`typescript`、`typescriptreact`、`vue`、`svelte`、`astro`。
- plugin spec 的 `ft` 与 `opts.filetypes` 必须复用同一份列表，不得分别维护两份值。
- 不允许 `filetypes = { "*" }`，也不允许 `event = "VeryLazy"`。
- 必须保留 `ColorizerAttachToBuffer`、`ColorizerDetachFromBuffer`、`ColorizerReloadAllBuffers`、`ColorizerToggle` 四个命令触发器。
- 必须保留 `user_default_options.css = true`。
- bigfile 清理只能读取 `package.loaded.colorizer`，不得调用 `require("colorizer")`。
- Colorizer 未加载、API 缺失、检查失败或 detach 失败时，不得中断既有 bigfile setup。
- 不修改 Bigfile 引用计数、窗口选项、MatchParen、Noice、Supermaven 或 Gitsigns 的现有生命周期语义。
- 手动 Colorizer 命令是用户显式覆盖；不额外禁止用户在非白名单普通 buffer 中手动附加。
- 使用严格 RED→GREEN；生产修改前必须先观察覆盖该行为的测试按预期失败。
- 使用仓库 `stylua.toml`；所有 Lua 改动完成后必须通过 StyLua 检查。
- 未经用户明确说“提交”或“commit”，不得创建 commit；不得 push。

---

## 文件职责与变更结构

- `lua/plugins/nvim-colorizer.lua`：定义 Colorizer 自动文件类型、lazy.nvim 精确触发器、手动命令和 CSS 解析选项。
- `lua/plugins/snacks.lua`：在现有 bigfile setup 中防御性分离已加载并附加的 Colorizer。
- `tests/colorizer_spec.lua`：验证 Colorizer spec 的文件类型、触发器、命令和选项契约。
- `tests/bigfile_spec.lua`：通过真实 Snacks bigfile 流程验证 Colorizer 未加载、已附加和异常路径。
- `scripts/check.sh`：将 `tests/colorizer_spec.lua` 纳入统一隔离验证。
- `tests/check_runner_spec.sh`：保护 Colorizer 测试阶段，确保 runner 不会漏跑。

---

### Task 1：将 Colorizer 改为精确文件类型与命令触发

**Files:**
- Create: `tests/colorizer_spec.lua`
- Modify: `lua/plugins/nvim-colorizer.lua`

**Interfaces:**
- Consumes: lazy.nvim plugin spec fields `ft`, `cmd`, `opts.filetypes`, `opts.user_default_options`。
- Produces: 一个自动文件类型共享表，以及四个上游用户命令的 lazy.nvim 触发器。

- [ ] **Step 1：创建 Colorizer spec 的失败测试**

创建 `tests/colorizer_spec.lua`：

```lua
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
```

- [ ] **Step 2：运行测试并确认 RED**

运行：

```bash
nvim --headless -u NORC '+luafile tests/colorizer_spec.lua' +qa
```

预期：非零退出；至少报告 `Colorizer must not use a broad event trigger`，因为生产 spec 仍包含 `event = "VeryLazy"` 和 `filetypes = { "*" }`。

- [ ] **Step 3：实现最小精确触发 spec**

将 `lua/plugins/nvim-colorizer.lua` 完整替换为：

```lua
local filetypes = {
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

return {
  "catgoose/nvim-colorizer.lua",
  ft = filetypes,
  cmd = {
    "ColorizerAttachToBuffer",
    "ColorizerDetachFromBuffer",
    "ColorizerReloadAllBuffers",
    "ColorizerToggle",
  },
  opts = {
    filetypes = filetypes,
    user_default_options = {
      css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
    },
  },
}
```

不要复制第二份文件类型列表，也不要加入额外文件类型。

- [ ] **Step 4：运行 focused GREEN 与格式检查**

运行：

```bash
nvim --headless -u NORC '+luafile tests/colorizer_spec.lua' +qa
stylua --config-path stylua.toml --check lua/plugins/nvim-colorizer.lua tests/colorizer_spec.lua
```

预期：

```text
OK Colorizer uses precise filetypes and preserves manual commands
```

StyLua 退出码为 0。

- [ ] **Step 5：检查 Task 1 差异**

运行：

```bash
git diff -- lua/plugins/nvim-colorizer.lua tests/colorizer_spec.lua
git diff --check
```

确认仅包含 Colorizer spec 和对应测试；不要提交。

---

### Task 2：为 Snacks bigfile 增加 Colorizer 防御性 detach

**Files:**
- Modify: `tests/bigfile_spec.lua`
- Modify: `lua/plugins/snacks.lua:69-88`

**Interfaces:**
- Consumes: `package.loaded.colorizer`；可选 API `is_buffer_attached(bufnr) -> boolean` 与 `detach_from_buffer(bufnr)`。
- Produces: bigfile setup 的非加载式 Colorizer 清理；不向其他模块暴露新接口。

- [ ] **Step 1：在真实 bigfile 测试中加入 Colorizer stub**

在 `tests/bigfile_spec.lua` 的 Noice stub 之前加入：

```lua
local colorizer = {
  detach_calls = {},
  fail_is_attached = false,
  fail_detach = false,
}

function colorizer.is_buffer_attached(buf)
  if colorizer.fail_is_attached then
    error("Colorizer attachment check failed")
  end
  return vim.b[buf].bigfile == true
end

function colorizer.detach_from_buffer(buf)
  if colorizer.fail_detach then
    error("Colorizer detach failed")
  end
  colorizer.detach_calls[#colorizer.detach_calls + 1] = buf
end

package.loaded.colorizer = colorizer
```

在 `cleanup_test_state()` 中加入：

```lua
  package.loaded.colorizer = colorizer
  package.preload.colorizer = nil
  colorizer.detach_calls = {}
  colorizer.fail_is_attached = false
  colorizer.fail_detach = false
```

- [ ] **Step 2：加入四个 bigfile Colorizer 回归场景**

在第一个现有 bigfile 生命周期测试之前加入：

```lua
test("detaches an already-loaded Colorizer only for bigfiles", function()
  edit(normal1)
  eq(colorizer.detach_calls, {}, "ordinary buffers must not run bigfile Colorizer cleanup")

  local big = edit(medium1)
  eq(colorizer.detach_calls, { big }, "bigfile setup must detach Colorizer from the detected buffer")
  delete_buffer(big)
end)

test("does not load Colorizer while opening a bigfile", function()
  package.loaded.colorizer = nil
  package.preload.colorizer = function()
    error("bigfile setup must not require Colorizer")
  end

  local big = edit(medium1)
  assert(package.loaded.colorizer == nil, "bigfile setup must leave unloaded Colorizer unloaded")
  delete_buffer(big)
end)

test("continues bigfile setup when Colorizer attachment checks fail", function()
  colorizer.fail_is_attached = true
  local big = edit(medium1)
  assert(vim.b[big].bigfile == true, "Colorizer check failure must not interrupt bigfile setup")
  eq(colorizer.detach_calls, {}, "failed attachment checks must not call detach")
  delete_buffer(big)
end)

test("continues bigfile setup when Colorizer detach fails", function()
  colorizer.fail_detach = true
  local big = edit(medium1)
  assert(vim.b[big].bigfile == true, "Colorizer detach failure must not interrupt bigfile setup")
  delete_buffer(big)
end)
```

- [ ] **Step 3：运行 bigfile 测试并确认 RED**

运行：

```bash
NVIM_TEST_LAZY_ROOT="$HOME/.local/share/nvim/lazy" \
  nvim --headless -u NORC '+luafile tests/bigfile_spec.lua' +qa
```

预期：非零退出；首个新增场景报告 bigfile 未调用 Colorizer detach。若失败来自 fixture 或语法错误，先修复测试，直到失败原因只剩生产清理缺失。

- [ ] **Step 4：实现非加载式 Colorizer 清理**

在 `lua/plugins/snacks.lua` 的 `vim.b.bigfile = true` 和 `Bigfile.enter(ctx.buf)` 之后、Gitsigns detach 之前加入：

```lua
        -- Colorizer 会注册 TextChanged* 和 WinScrolled 重绘；大文件只清理
        -- 已加载并附加的实例，不能因减负逻辑反向加载插件。
        local colorizer = package.loaded.colorizer
        if
          colorizer
          and type(colorizer.is_buffer_attached) == "function"
          and type(colorizer.detach_from_buffer) == "function"
        then
          local ok_attached, attached = pcall(colorizer.is_buffer_attached, ctx.buf)
          if ok_attached and attached then
            pcall(colorizer.detach_from_buffer, ctx.buf)
          end
        end
```

不要调用 `require("colorizer")`，不要改变 Gitsigns、Noice 或 Bigfile 的原有顺序和所有权逻辑。

- [ ] **Step 5：运行 focused GREEN**

运行：

```bash
NVIM_TEST_LAZY_ROOT="$HOME/.local/share/nvim/lazy" \
  nvim --headless -u NORC '+luafile tests/bigfile_spec.lua' +qa
stylua --config-path stylua.toml --check lua/plugins/snacks.lua tests/bigfile_spec.lua
```

预期：bigfile 测试打印现有成功消息并以 0 退出；StyLua 以 0 退出。

- [ ] **Step 6：检查 Task 2 差异**

运行：

```bash
git diff -- lua/plugins/snacks.lua tests/bigfile_spec.lua
git diff --check
```

确认 Colorizer 清理不改变其他 bigfile 生命周期逻辑；不要提交。

---

### Task 3：接入统一 checker 并完成行为验收

**Files:**
- Modify: `tests/check_runner_spec.sh:163-176`
- Modify: `scripts/check.sh:235-246`
- Test: `tests/colorizer_spec.lua`
- Test: `tests/bigfile_spec.lua`

**Interfaces:**
- Consumes: `run_nvim_lua_test` 和 runner 的阶段输出断言。
- Produces: `CHECK: tests/colorizer_spec.lua` 统一验证阶段及缺失阶段回归保护。

- [ ] **Step 1：先增加 runner 阶段验收**

在 `tests/check_runner_spec.sh` 的成功阶段列表中，将：

```bash
  'documentation_spec.lua' \
  'bigfile_spec.lua' \
```

改为：

```bash
  'documentation_spec.lua' \
  'colorizer_spec.lua' \
  'bigfile_spec.lua' \
```

- [ ] **Step 2：运行 runner 并确认 RED**

运行：

```bash
bash tests/check_runner_spec.sh
```

预期：非零退出并包含：

```text
FAIL: missing output: colorizer_spec.lua
```

- [ ] **Step 3：注册统一 Colorizer 测试阶段**

在 `scripts/check.sh` 中将：

```bash
run_stage 'tests/documentation_spec.lua' run_nvim_lua_test tests/documentation_spec.lua
run_stage 'tests/bigfile_spec.lua' run_nvim_lua_test tests/bigfile_spec.lua
```

改为：

```bash
run_stage 'tests/documentation_spec.lua' run_nvim_lua_test tests/documentation_spec.lua
run_stage 'tests/colorizer_spec.lua' run_nvim_lua_test tests/colorizer_spec.lua
run_stage 'tests/bigfile_spec.lua' run_nvim_lua_test tests/bigfile_spec.lua
```

- [ ] **Step 4：运行完整 GREEN 验证**

依次运行：

```bash
stylua --config-path stylua.toml --check init.lua lua tests
scripts/check.sh
bash tests/check_runner_spec.sh
bash -n scripts/check.sh tests/check_runner_spec.sh
git diff --check
```

预期：

- StyLua 退出码 0；
- checker 出现 `CHECK: tests/colorizer_spec.lua`；
- Colorizer 测试打印 `OK Colorizer uses precise filetypes and preserves manual commands`；
- bigfile、最小启动及所有既有测试继续通过；
- runner 打印 `OK check runner uses isolated read-only plugin snapshots and propagates failures`；
- Shell 语法与 diff 检查无输出、退出码 0。

- [ ] **Step 5：执行最终范围与行为审计**

运行：

```bash
git status --short
git diff --stat
git diff -- lua/plugins/nvim-colorizer.lua lua/plugins/snacks.lua tests/colorizer_spec.lua tests/bigfile_spec.lua scripts/check.sh tests/check_runner_spec.sh
git grep -n 'filetypes =.*"\*"' -- lua/plugins/nvim-colorizer.lua || true
git grep -n 'require("colorizer")' -- lua/plugins/snacks.lua || true
```

实现差异必须只包含：

```text
lua/plugins/nvim-colorizer.lua
lua/plugins/snacks.lua
scripts/check.sh
tests/bigfile_spec.lua
tests/check_runner_spec.sh
tests/colorizer_spec.lua
```

当前尚未提交的设计与计划文档会继续出现在工作区，但不属于实现 diff：

```text
docs/superpowers/specs/2026-07-24-colorizer-scope-design.md
docs/superpowers/plans/2026-07-28-colorizer-scope.md
```

最后两条 grep 不应命中生产文件。

- [ ] **Step 6：进行独立任务审查**

生成包含完整 tracked/untracked diff 的审查包，分别检查：

1. 规格符合性：12 个文件类型、四个命令、CSS 解析、bigfile 非加载式 detach、统一 checker。
2. 代码质量：lazy.nvim 命令触发语义、`package.loaded` 使用、异常吞吐边界、测试是否真实覆盖未加载与 detach 失败路径。

修复所有 Critical、Important 和 Minor 发现后重新运行 Step 4。未经用户明确要求，不提交、不 push。
