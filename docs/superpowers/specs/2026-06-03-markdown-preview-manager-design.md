# markdown-preview.nvim 预览管理增强 — 设计

日期：2026-06-03
分支：nvim-0.11

## 背景

`iamcco/markdown-preview.nvim` 已多年未更新。我们想增强它，但**不依赖 upstream 更新、不 fork**——全部增强加在本仓库配置里。

经源码分析确认：插件 Neovim 侧（启动 node 服务、按 `bufnr` 维护 `/page/<bufnr>` 页面、websocket 同步）是稳定的，三个痛点均可在配置层解决：

- 重写 `gom` 的 toggle 逻辑（不动插件文件）
- 用官方钩子 `g:mkdp_browserfunc` 捕获每个 buffer 的预览 URL
- 复用现有 HTML 注入机制（`patch_toc_sidebar`）注入一段链接处理 JS

## 痛点与根因

### 痛点 1：gom 关闭会杀掉整个服务，只能预览一个文件

根因在 `autoload/mkdp/util.vim`：

```vim
function! mkdp#util#toggle_preview() abort
    if !get(b:, 'MarkdownPreviewToggleBool')
        call mkdp#util#open_preview_page()
        let b:MarkdownPreviewToggleBool=1
    else
        call mkdp#util#stop_preview()   " ← 问题在这
        let b:MarkdownPreviewToggleBool=0
    endif
endfunction
```

开关状态按 buffer 记（`b:MarkdownPreviewToggleBool`），但关闭走 `stop_preview()` → `stop_server()`，会**杀掉整个 node 进程 + close_all_pages**。于是任意 buffer 按 gom 关闭就连带杀死所有其它文件的预览。

插件其实原生支持多文件：server 按 `bufnr` 分别维护页面，`mkdp#rpc#preview_close()` 只关单个 buffer 的页面而**不停服务**（发送 `close_page` notify，携带 `bufnr('%')`）。

### 痛点 2：想要一个 fzf 式窗口列出所有预览并跳转

URL 确定为 `http://localhost:<port>/page/<bufnr>`（见 `app/server.js`，port 为 `g:mkdp_port` 或 `8080 + Date.now() 后三位`）。`g:mkdp_browserfunc` 钩子在每次开预览时被服务端以 URL 调用，可借此捕获精确 URL。

### 痛点 3：点链接同标签页跳转、回退后 404

`app/routes.js` 中 `/page/\d+` 路由只 serve `out/index.html`；任何相对/外部链接跳走后，浏览器回退命中的是兜底的 404 路由（serve `out/404.html`）。

## 方案

### 总体结构（不动插件源码）

- 新增模块 `lua/plugins/mkdp/manager.lua`：预览管理器。职责：
  - 维护注册表 `registry: bufnr → { name = <文件名>, url = <预览url> }`
  - `toggle()`：自定义按 buffer 的开关逻辑
  - `browserfunc(url)`：被 `g:mkdp_browserfunc` 调用，记录 URL 并打开浏览器
  - `pick()`：fzf-lua 列表窗口
  - `stop_one(bufnr)` / `stop_all()`：停止单个 / 全部
- `lua/plugins/markdown-preview.lua`：
  - `gom` 键位改为调 `manager.toggle()`
  - 新增列表窗口键位（建议 `goM`），调 `manager.pick()`
  - `init` 中设置 `vim.g.mkdp_browserfunc = 'MkdpBrowserFunc'`（一个转发到 Lua `manager.browserfunc` 的 vim 函数）
  - 不设固定 `g:mkdp_port`（避免端口冲突；URL 由 browserfunc 实时捕获）
- 注入：复用现有 `patch_*` 机制，新增 `assets/mkdp/links.js` 并注入到 `out/index.html`。

### 痛点 1 实现：真正的按文件开关、服务常驻

`manager.toggle()`（以注册表为准，不依赖 `b:MarkdownPreviewToggleBool`）：

- 当前 buffer **未** active → `vim.fn['mkdp#util#open_preview_page']()`（服务未起会自动起），标记 bufnr active。URL 由 browserfunc 异步回填。
- 当前 buffer **已** active → `vim.fn['mkdp#rpc#preview_close']()`（只关当前 buffer 页面，**服务进程保留**），从注册表移除 bufnr。

多个 md 文件因此可同时各自预览，互不影响。**不再保留单独的"停服务"命令**——彻底停服务放进列表窗口（按用户选择）。

### 痛点 2 实现：fzf-lua 预览列表窗口

- vimscript 转发函数（在插件 spec 的 `init` 里定义）：

  ```vim
  function! MkdpBrowserFunc(url) abort
    call luaeval('require("plugins.mkdp.manager").browserfunc(_A)', a:url)
  endfunction
  ```

- `manager.browserfunc(url)`：从 url 用模式 `/page/(%d+)` 解析出 bufnr，配 `nvim_buf_get_name(bufnr)` 取文件名，写入注册表，然后 `vim.ui.open(url)` 实际打开浏览器。
- `manager.pick()`（fzf-lua）：
  - 数据来源：注册表，按 `nvim_buf_is_valid(bufnr)` 过滤失效项。
  - 每行显示：文件名 + 相对路径。
  - 键位：
    - `Enter` → `vim.ui.open(url)`（浏览器打开/聚焦该页）—— 默认动作
    - `ctrl-x` → 停止选中预览：`vim.api.nvim_buf_call(bufnr, function() vim.fn['mkdp#rpc#preview_close']() end)`，并从注册表移除（服务保留）
    - `ctrl-q` → 停止全部 / 关服务：`vim.fn['mkdp#util#stop_preview']()`，清空注册表
  - 注册表为空 → 提示「当前没有活动的预览」。

### 痛点 3 实现：链接不带走预览页

新增 `assets/mkdp/links.js`，事件委托处理动态渲染内容：

```js
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

外链 `http(s)` 在新标签页打开，预览标签页不被导航走，故不再回退到 404。相对/本地链接保持原样（用户选择"够用即可"）。

注入：把现有 `patch_toc_sidebar()` 泛化（或新增并列的 `patch_links()`）——把 `assets/mkdp/links.js` 复制进插件 `app/_static/`，并在 `out/index.html` 的 `</head>` 前注入 `<script src="/_static/links.js" defer></script>`（带幂等判断，已注入则跳过）。

## 数据流

```
gom (toggle)
  └─ manager.toggle()
       ├─ open: mkdp#util#open_preview_page()  → node server → MkdpBrowserFunc(url)
       │                                                          └─ manager.browserfunc(url): 记录 + vim.ui.open
       └─ close: mkdp#rpc#preview_close()       → node 关单页（服务存活）

goM (pick)
  └─ manager.pick() → fzf-lua(registry)
       ├─ Enter  → vim.ui.open(url)
       ├─ ctrl-x → nvim_buf_call(bufnr, preview_close) + registry 移除
       └─ ctrl-q → mkdp#util#stop_preview() + registry 清空

注入：build/config 阶段 patch out/index.html  ← assets/mkdp/links.js
浏览器点击外链 → links.js 拦截 → window.open(_blank)
```

## 边界与失效处理

- 注册表项的 bufnr 失效（buffer 被删）：`pick()` 时过滤。
- 浏览器标签被用户手动关闭：Neovim 侧无法感知，`pick()` 仍列出该项；Enter 会重新打开——可接受。
- 服务在会话内常驻；`VimLeave` 时插件自带 autocmd 停服务。会话内 URL（含 port）保持稳定，注册表不会因端口变动失效。
- `open_preview_page` 异步启动服务：toggle 时乐观标记 bufnr active，URL 由 browserfunc 到达时回填；`pick()` 对尚无 url 的项可暂不显示或显示「启动中」。

## 测试策略

手动验证（无现成自动化测试框架）：

1. 痛点 1：打开 A.md 按 gom；打开 B.md 按 gom；回到 A 按 gom 关闭 → B 的预览仍存活。
2. 痛点 2：开两个预览，`goM` 列表显示两项；Enter 打开对应页；`ctrl-x` 停其一、另一存活；`ctrl-q` 全停。
3. 痛点 3：预览含外链，点击 → 新标签页打开，预览页不动；无 404。
4. bigfile 兼容：超长行 markdown 下 gom 仍能预览（沿用现有 `mkdp_command_for_global`）。

## 范围外（YAGNI）

- 相对/本地 `.md` 链接的智能跳转（打开目标文件预览）——不做。
- 跨 Neovim 会话持久化注册表——不做。
- combine preview 模式——不涉及。
