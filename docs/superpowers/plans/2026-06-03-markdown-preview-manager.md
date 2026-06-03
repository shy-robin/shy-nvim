# markdown-preview.nvim 预览管理增强 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不动 `markdown-preview.nvim` 源码、不 fork 的前提下，让 `gom` 按文件开关且服务常驻、新增 fzf-lua 预览列表窗口、点外链不再把预览页带走。

**Architecture:** 新增纯 Neovim 侧模块 `lua/util/mkdp.lua`（注册表 + 自定义 toggle + browserfunc 钩子 + fzf-lua 选择窗口），在插件 spec 里改写 `gom`、新增 `goM`、设置 `g:mkdp_browserfunc`；并复用现有 HTML 注入机制注入一段 `links.js` 让外链开新标签页。

**Tech Stack:** Lua（Neovim 0.11 API、`vim.ui.open`）、Vimscript autoload 函数（`mkdp#...`）、fzf-lua、原生 JS（注入到预览页）。

参考设计：`docs/superpowers/specs/2026-06-03-markdown-preview-manager-design.md`

**关键约束（务必遵守）：**
- 模块放 `lua/util/mkdp.lua`，**不要**放 `lua/plugins/` 下——lazy.nvim 会递归把 `lua/plugins/` 里的文件当插件 spec 加载。
- 该模块顶层只定义 table 与函数；`fzf-lua` 只在 `pick()` 内部 `require`，保证可在 headless（无插件）下被 require 进行单元测试。
- 没有现成测试框架；纯函数用 `nvim --headless` 跑断言脚本，集成行为用明确的手动验证步骤。
- 所有命令从仓库根目录 `/Users/shyrobin/.config/nvim` 执行。

---

## 文件结构

- Create: `lua/util/mkdp.lua` — 预览管理器（注册表、`bufnr_from_url`、`browserfunc`、`toggle`、`stop_one`、`stop_all`、`pick`）
- Create: `tests/mkdp_spec.lua` — `bufnr_from_url` 的 headless 断言测试
- Create: `assets/mkdp/links.js` — 注入预览页的外链处理脚本
- Modify: `lua/plugins/markdown-preview.lua` — 改写 `gom`、新增 `goM`、设 `g:mkdp_browserfunc` 与 `MkdpBrowserFunc`、新增 `links.js` 注入

---

## Task 1: 预览管理器模块 + bufnr 解析（痛点 1/2 基础）

**Files:**
- Create: `lua/util/mkdp.lua`
- Test: `tests/mkdp_spec.lua`

- [ ] **Step 1: 写失败的测试**

创建 `tests/mkdp_spec.lua`：

```lua
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
```

- [ ] **Step 2: 运行测试确认失败**

Run: `nvim --headless -u NORC +"luafile tests/mkdp_spec.lua" +qa`
Expected: 报错，因 `util.mkdp` 模块尚不存在（`module 'util.mkdp' not found`）。

- [ ] **Step 3: 写最小实现**

创建 `lua/util/mkdp.lua`：

```lua
-- markdown-preview.nvim 预览管理器
-- 职责：按 buffer 维护预览注册表、自定义 toggle（服务常驻）、fzf-lua 选择窗口。
-- 注意：放在 lua/util/ 而非 lua/plugins/，避免被 lazy.nvim 当作插件 spec 加载。
local M = {}

-- bufnr -> { name = <buffer 全名>, url = <预览 url 或 nil> }
M.registry = {}

-- 从 http://host:port/page/<bufnr> 解析出 bufnr
function M.bufnr_from_url(url)
  if type(url) ~= "string" then
    return nil
  end
  local n = url:match("/page/(%d+)")
  return n and tonumber(n) or nil
end

return M
```

- [ ] **Step 4: 运行测试确认通过**

Run: `nvim --headless -u NORC +"luafile tests/mkdp_spec.lua" +qa`
Expected: 输出 `OK mkdp bufnr_from_url`，无报错。

- [ ] **Step 5: 提交**

```bash
git add lua/util/mkdp.lua tests/mkdp_spec.lua
git commit -m "feat(mkdp): 新增预览管理器模块与 bufnr 解析"
```

---

## Task 2: 注册表读写 + browserfunc + 开关逻辑（痛点 1）

**Files:**
- Modify: `lua/util/mkdp.lua`

- [ ] **Step 1: 扩展模块——browserfunc、is_active、toggle、stop_one、stop_all、active_entries**

在 `lua/util/mkdp.lua` 的 `return M` 之前插入以下函数：

```lua
-- g:mkdp_browserfunc 经 vimscript MkdpBrowserFunc 转发到这里：
-- 记录该 buffer 的精确预览 url，然后实际打开浏览器。
function M.browserfunc(url)
  local bufnr = M.bufnr_from_url(url)
  if bufnr then
    M.registry[bufnr] = {
      name = vim.api.nvim_buf_get_name(bufnr),
      url = url,
    }
  end
  vim.ui.open(url)
end

function M.is_active(bufnr)
  return M.registry[bufnr] ~= nil
end

-- gom：按当前 buffer 开关预览，node 服务进程常驻供其它文件继续使用。
function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  if M.is_active(bufnr) then
    -- 只关当前 buffer 的页面，不停服务
    vim.fn["mkdp#rpc#preview_close"]()
    M.registry[bufnr] = nil
  else
    -- 乐观登记；url 由 browserfunc 异步回填
    M.registry[bufnr] = { name = vim.api.nvim_buf_get_name(bufnr), url = nil }
    vim.fn["mkdp#util#open_preview_page"]()
  end
end

-- 停止单个 buffer 的预览（服务保留）。
-- 用 nvim_buf_call 让 mkdp#rpc#preview_close 内部的 bufnr('%') 命中目标 buffer。
function M.stop_one(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_call(bufnr, function()
      vim.fn["mkdp#rpc#preview_close"]()
    end)
  end
  M.registry[bufnr] = nil
end

-- 停止全部并关掉整个服务。
function M.stop_all()
  vim.fn["mkdp#util#stop_preview"]()
  M.registry = {}
end

-- 收集有效的活动预览条目（顺手清理失效 bufnr）。
function M.active_entries()
  local items = {}
  for bufnr, info in pairs(M.registry) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      table.insert(items, { bufnr = bufnr, name = info.name, url = info.url })
    else
      M.registry[bufnr] = nil
    end
  end
  table.sort(items, function(a, b)
    return a.bufnr < b.bufnr
  end)
  return items
end
```

- [ ] **Step 2: 运行已有测试确认未回归**

Run: `nvim --headless -u NORC +"luafile tests/mkdp_spec.lua" +qa`
Expected: 仍输出 `OK mkdp bufnr_from_url`（require 模块不应因新增函数报错；新增函数体内引用 `vim.ui`/`mkdp#...` 但未在 require 时执行）。

- [ ] **Step 3: 提交**

```bash
git add lua/util/mkdp.lua
git commit -m "feat(mkdp): 注册表、browserfunc 钩子与按 buffer 开关逻辑"
```

---

## Task 3: 接线 gom toggle + browserfunc（痛点 1 收尾）

**Files:**
- Modify: `lua/plugins/markdown-preview.lua`

- [ ] **Step 1: 在 init 中设置 browserfunc 与转发函数**

修改 `lua/plugins/markdown-preview.lua` 的 `init` 函数，在现有 `vim.g.mkdp_*` 设置之后、`init` 结束之前加入：

```lua
    -- 用官方钩子捕获每个 buffer 的精确预览 URL，并由管理器统一打开浏览器。
    vim.g.mkdp_browserfunc = "MkdpBrowserFunc"
    vim.cmd([[
      function! MkdpBrowserFunc(url) abort
        call luaeval('require("util.mkdp").browserfunc(_A)', a:url)
      endfunction
    ]])
```

注意：保留现有的 `vim.g.mkdp_browser = ""`、`vim.g.mkdp_echo_preview_url`、`vim.g.mkdp_auto_close = 0` 等设置不变。

- [ ] **Step 2: 把 gom 改为调用管理器 toggle**

将 `keys` 表中现有这一行：

```lua
  keys = { { "gom", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" } },
```

替换为：

```lua
  keys = {
    { "gom", function() require("util.mkdp").toggle() end, desc = "Markdown Preview Toggle", ft = "markdown" },
  },
```

- [ ] **Step 3: 手动验证多文件预览与服务常驻**

Run: 在终端打开 nvim，依次操作（需本机有浏览器）：
1. `nvim A.md`（任意 markdown 文件），按 `gom` → 浏览器打开 A 的预览。
2. `:e B.md`，按 `gom` → 浏览器再开 B 的预览（A 仍在）。
3. 切回 A（`:b A.md` 或 `<C-^>`），按 `gom` 关闭 A。

Expected: 第 3 步关闭 A 后，**B 的预览页仍然存活/可刷新**（不再像旧行为那样整个服务被杀）。若 B 预览页变白/断连即为失败。

- [ ] **Step 4: 提交**

```bash
git add lua/plugins/markdown-preview.lua
git commit -m "feat(mkdp): gom 改为按 buffer 开关、服务常驻 + browserfunc 接线"
```

---

## Task 4: fzf-lua 预览列表窗口（痛点 2）

**Files:**
- Modify: `lua/util/mkdp.lua`
- Modify: `lua/plugins/markdown-preview.lua`

- [ ] **Step 1: 在管理器中实现 pick()**

在 `lua/util/mkdp.lua` 的 `return M` 之前加入：

```lua
-- fzf-lua 选择窗口：列出所有活动预览。
-- Enter=浏览器打开/聚焦该页；ctrl-x=停止选中（服务保留）；ctrl-q=停止全部并关服务。
function M.pick()
  local entries = M.active_entries()
  if #entries == 0 then
    vim.notify("当前没有活动的预览", vim.log.levels.INFO)
    return
  end

  local display, lookup = {}, {}
  for _, e in ipairs(entries) do
    local full = (e.name ~= "" and e.name) or ("[buffer " .. e.bufnr .. "]")
    local label = vim.fn.fnamemodify(full, ":t")
    local rel = vim.fn.fnamemodify(full, ":~:.")
    local line = string.format("%s\t%s", label, rel)
    table.insert(display, line)
    lookup[line] = e
  end

  local fzf = require("fzf-lua")
  fzf.fzf_exec(display, {
    prompt = "MarkdownPreview❯ ",
    actions = {
      ["default"] = function(selected)
        local e = selected and selected[1] and lookup[selected[1]]
        if e and e.url then
          vim.ui.open(e.url)
        elseif e then
          vim.notify("该预览尚未就绪（URL 未回填）", vim.log.levels.WARN)
        end
      end,
      ["ctrl-x"] = function(selected)
        local e = selected and selected[1] and lookup[selected[1]]
        if e then
          M.stop_one(e.bufnr)
          vim.notify("已停止预览：" .. (e.name ~= "" and vim.fn.fnamemodify(e.name, ":t") or e.bufnr))
        end
      end,
      ["ctrl-q"] = function()
        M.stop_all()
        vim.notify("已停止全部预览并关闭服务", vim.log.levels.INFO)
      end,
    },
  })
end
```

- [ ] **Step 2: 新增 goM 键位触发 pick**

在 `lua/plugins/markdown-preview.lua` 的 `keys` 表中，`gom` 那一项之后加入新项（注意 `goM` 不限 ft，便于任意处呼出列表）：

```lua
    { "goM", function() require("util.mkdp").pick() end, desc = "Markdown Preview List" },
```

修改后 `keys` 应为：

```lua
  keys = {
    { "gom", function() require("util.mkdp").toggle() end, desc = "Markdown Preview Toggle", ft = "markdown" },
    { "goM", function() require("util.mkdp").pick() end, desc = "Markdown Preview List" },
  },
```

- [ ] **Step 3: 手动验证列表窗口三种动作**

Run: 在 nvim 中打开两个 md 文件、各按 `gom` 开预览，然后按 `goM`：
1. 列表应显示两项（文件名 + 相对路径）。
2. 选中一项回车 → 浏览器打开/聚焦对应预览页。
3. 再 `goM`，对某项按 `ctrl-x` → 该预览停止、另一项仍在。
4. 再 `goM`，按 `ctrl-q` → 全部停止；此后 `goM` 提示「当前没有活动的预览」。

Expected: 三种动作行为如上；空列表时给出 notify 提示。

- [ ] **Step 4: 提交**

```bash
git add lua/util/mkdp.lua lua/plugins/markdown-preview.lua
git commit -m "feat(mkdp): 新增 fzf-lua 预览列表窗口 (goM)"
```

---

## Task 5: 外链开新标签页，预览页不再 404（痛点 3）

**Files:**
- Create: `assets/mkdp/links.js`
- Modify: `lua/plugins/markdown-preview.lua`

- [ ] **Step 1: 创建注入脚本**

创建 `assets/mkdp/links.js`：

```js
// 让预览页里的 http(s) 外链在新标签页打开，避免导航走预览页后回退命中 404。
// 用捕获阶段的事件委托，兼容 socket 刷新后动态重渲染的内容。
document.addEventListener('click', function (e) {
  var a = e.target.closest && e.target.closest('a[href]')
  if (!a) return
  var href = a.getAttribute('href') || ''
  if (/^https?:\/\//i.test(href)) {
    e.preventDefault()
    window.open(href, '_blank', 'noopener')
  }
}, true)
```

- [ ] **Step 2: 新增注入函数并在 build/config 调用**

在 `lua/plugins/markdown-preview.lua` 中，于现有 `patch_toc_sidebar` 函数之后新增并列函数 `patch_link_handler`：

```lua
local function patch_link_handler()
  local plugin_dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
  local static_dir = plugin_dir .. "/app/_static"
  local out_html = plugin_dir .. "/app/out/index.html"
  local src = vim.fn.stdpath("config") .. "/assets/mkdp/links.js"

  if vim.fn.isdirectory(static_dir) == 0 or vim.fn.filereadable(out_html) == 0 then
    return
  end
  if vim.fn.filereadable(src) == 0 then
    return
  end

  -- 复制（变更才写）
  local dst = static_dir .. "/links.js"
  local src_lines = vim.fn.readfile(src, "b")
  if vim.fn.filereadable(dst) == 1 then
    local dst_lines = vim.fn.readfile(dst, "b")
    if not vim.deep_equal(src_lines, dst_lines) then
      vim.fn.writefile(src_lines, dst, "b")
    end
  else
    vim.fn.writefile(src_lines, dst, "b")
  end

  -- 注入（幂等）
  local lines = vim.fn.readfile(out_html)
  if not lines or #lines == 0 then
    return
  end
  local html = table.concat(lines, "\n")
  if html:find("links%.js", 1, false) then
    return
  end
  local inject = '<script src="/_static/links.js" defer></script>'
  local patched, n = html:gsub("</head>", inject .. "</head>", 1)
  if n == 1 then
    vim.fn.writefile(vim.split(patched, "\n", { plain = true }), out_html)
  end
end
```

然后在 `build` 函数与 `config` 函数中，分别在调用 `patch_toc_sidebar()` 之后加一行 `patch_link_handler()`：

build 函数改为：

```lua
  build = function(plugin)
    vim.fn.system({ "sh", "-c", "cd " .. vim.fn.shellescape(plugin.dir) .. "/app && npx --yes yarn install" })
    patch_toc_sidebar()
    patch_link_handler()
  end,
```

config 函数改为：

```lua
  config = function()
    patch_toc_sidebar()
    patch_link_handler()
  end,
```

- [ ] **Step 3: 触发一次注入并验证 HTML 已打补丁**

Run（先在 nvim 内触发一次预览以确保 `config` 跑过，或直接重启 nvim 打开 md 文件后）：

```bash
grep -c "links.js" "$HOME/.local/share/nvim/lazy/markdown-preview.nvim/app/out/index.html"
```

Expected: 输出 `1`（已注入且仅注入一次）。
若输出 `0`：先在 nvim 打开任意 markdown 触发插件 `config`，或运行 `:Lazy build markdown-preview.nvim` 后重试。

- [ ] **Step 4: 手动验证外链行为**

Run: 准备一个含外链（如 `[google](https://google.com)`）的 md，`gom` 预览后在浏览器点击该链接。
Expected: 链接在**新标签页**打开；预览标签页停留原处，不发生导航、不出现 404。

- [ ] **Step 5: 提交**

```bash
git add assets/mkdp/links.js lua/plugins/markdown-preview.lua
git commit -m "feat(mkdp): 注入 links.js 让外链开新标签页，避免回退 404"
```

---

## 自检结果

**Spec 覆盖：**
- 痛点 1（按 buffer 开关、服务常驻）→ Task 2（toggle/stop 逻辑）+ Task 3（接线 gom）。
- 痛点 2（fzf-lua 列表、Enter 打开、停单个/全部）→ Task 1（registry/解析）+ Task 2（browserfunc/stop）+ Task 4（pick + goM）。
- 痛点 3（外链开新标签）→ Task 5（links.js + 注入）。
- 不设固定 `g:mkdp_port`：Task 3 未设置 port，符合设计。
- bigfile 兼容：沿用现有 `mkdp_command_for_global` 设置，未改动。

**占位符扫描：** 无 TBD/TODO；每个改码步骤均含完整代码与确切命令。

**类型/命名一致性：** 模块函数名贯穿一致——`bufnr_from_url`、`browserfunc`、`is_active`、`toggle`、`stop_one`、`stop_all`、`active_entries`、`pick`；require 路径统一 `util.mkdp`；vimscript 转发函数统一 `MkdpBrowserFunc`；注入文件统一 `links.js`（`assets/mkdp/links.js` → `_static/links.js`）；键位 `gom`/`goM`、fzf 动作键 `ctrl-x`/`ctrl-q` 前后一致。
