# Colorizer 精确加载与 bigfile 隔离设计

## 背景

当前 `nvim-colorizer.lua` 在 `VeryLazy` 后加载，并以 `filetypes = { "*" }` 自动附加到所有普通文件类型。Colorizer 会为已附加 buffer 注册 `TextChanged`、`TextChangedI`、`TextChangedP` 和 `WinScrolled` 等回调，因此 Lua、Markdown、帮助、日志等通常不需要颜色解析的 buffer 也承担持续扫描和重绘成本。

现有 Snacks bigfile 流程会关闭或分离 Treesitter、补全、格式化、Gitsigns、Noice 等高成本功能，但没有显式处理 Colorizer。如果 Colorizer 在文件类型变化或加载时序中提前附加，大文件仍可能保留颜色扫描回调。

## 目标

1. Colorizer 只在可能包含前端颜色表达式的文件类型中自动加载和附加。
2. Lua、Markdown、帮助、日志、终端和 bigfile buffer 不自动加载 Colorizer。
3. bigfile 流程能够防御性分离已经附加的 Colorizer，但不能因此加载插件。
4. 保留 Colorizer 用户命令，允许用户在未列入白名单的普通 buffer 中显式启用。
5. 不改变前端文件中现有的完整 CSS 颜色解析能力。
6. 为加载边界和 bigfile 清理增加可重复的自动化验证。

## 非目标

- 不修改 Colorizer 上游实现。
- 不重构现有 bigfile 生命周期、Noice 状态或窗口选项恢复逻辑。
- 不增加新的颜色格式、显示模式或快捷键。
- 不禁止用户在普通非白名单 buffer 中通过命令手动启用 Colorizer。
- 不以主观启动时间数据替代结构和行为回归测试。

## 方案选择

采用“文件类型白名单 + bigfile 防御性 detach”。

未采用的方案：

- 仅排除 bigfile：无法消除 Lua、Markdown、帮助等日常 buffer 的无效回调。
- 完全手动启用：虽然开销最低，但会显著降低前端文件的默认使用体验。

## 自动启用范围

Colorizer 的自动文件类型列表固定为：

- `css`
- `scss`
- `sass`
- `less`
- `html`
- `javascript`
- `javascriptreact`
- `typescript`
- `typescriptreact`
- `vue`
- `svelte`
- `astro`

插件 spec 的 `ft` 触发器和 Colorizer `opts.filetypes` 必须复用同一份列表或由同一份常量生成，避免加载范围与自动附加范围漂移。

继续保留：

```lua
user_default_options = {
  css = true,
}
```

以维持 RGB/HSL 函数、颜色名称、十六进制等现有 CSS 解析行为。

## 手动入口

保留 Colorizer 上游用户命令作为 lazy.nvim 命令触发器：

- `ColorizerAttachToBuffer`
- `ColorizerDetachFromBuffer`
- `ColorizerReloadAllBuffers`
- `ColorizerToggle`

这些命令允许用户在未列入自动白名单的普通 buffer 中显式覆盖默认行为。手动覆盖属于用户主动选择，不作为自动加载回归。

## bigfile 隔离

在现有 Snacks bigfile `setup(ctx)` 中加入 Colorizer 清理，位置应在设置 `vim.b.bigfile = true` 之后，并与 Gitsigns 等渲染功能的减负逻辑相邻。

清理规则：

1. 仅读取 `package.loaded.colorizer`，不得调用 `require("colorizer")`。
2. 如果模块未加载，不执行任何操作。
3. 如果模块已加载：
   - 优先检查 `is_buffer_attached(ctx.buf)`；
   - 已附加时调用 `detach_from_buffer(ctx.buf)`；
   - 检查或 detach 失败均由 `pcall` 吸收，不得中断后续 bigfile setup。
4. 不负责在 bigfile 关闭后重新附加 Colorizer，因为 bigfile 的文件类型不属于自动白名单；用户也不应在关闭大文件 buffer 后恢复该 buffer 的颜色扫描。

正常路径下，Snacks 将大文件的文件类型设置为 `bigfile`，该类型不在 Colorizer 白名单中，因此不会自动附加。防御性 detach 只处理插件已加载、文件类型变化或 autocmd 顺序造成的竞态。

## 文件变更范围

预计修改：

- `lua/plugins/nvim-colorizer.lua`
- `lua/plugins/snacks.lua`
- `scripts/check.sh`
- `tests/check_runner_spec.sh`

预计新增：

- `tests/colorizer_spec.lua`

除非实施时发现 README 已承诺 Colorizer 对所有文件类型自动生效，否则不修改用户文档。

## 测试设计

新增 `tests/colorizer_spec.lua`，通过读取真实 plugin spec 和模拟已加载 Colorizer 模块验证以下行为：

### Spec 与触发器

- plugin spec 不再使用 `event = "VeryLazy"`。
- `ft` 与 `opts.filetypes` 使用相同的自动文件类型集合。
- 集合必须等于设计中的 12 个文件类型，不允许 `"*"`。
- `bigfile`、`lua`、`markdown`、`help`、`log` 和 `terminal` 不在自动列表中。
- 保留四个 Colorizer 用户命令的 lazy.nvim `cmd` 触发器。
- `user_default_options.css` 仍为 `true`。

### bigfile 清理

- Colorizer 未加载时，执行 bigfile setup 不得加载模块或报错。
- Colorizer 已加载但未附加当前 buffer 时，不调用 detach。
- Colorizer 已附加当前 buffer 时，调用 `detach_from_buffer(ctx.buf)`。
- `is_buffer_attached` 报错时，bigfile setup 继续执行。
- `detach_from_buffer` 报错时，bigfile setup 继续执行。
- 测试必须证明清理使用 `package.loaded`，而不是 `require`。

### 验证入口

- 将 `tests/colorizer_spec.lua` 接入 `scripts/check.sh`。
- 在 `tests/check_runner_spec.sh` 中断言该阶段存在。
- 保持现有隔离 HOME/XDG/TMPDIR、只读插件快照和失败传播语义。

## 验收标准

自动化验收：

```text
scripts/check.sh
bash tests/check_runner_spec.sh
stylua --config-path stylua.toml --check init.lua lua tests
bash -n scripts/check.sh tests/check_runner_spec.sh
git diff --check
```

行为验收：

1. 打开 Lua 或 Markdown 文件时，Colorizer 不因文件类型自动加载。
2. 打开 CSS、Vue、Svelte、JavaScript 或 TypeScript 文件时，Colorizer 自动加载并显示颜色。
3. 打开被 Snacks 识别为 `bigfile` 的文件时，该 buffer 不保留 Colorizer 的 `TextChanged*` 或 `WinScrolled` 回调。
4. 在未列入白名单的普通 buffer 中执行 `:ColorizerAttachToBuffer` 仍可显式启用。
5. 现有 bigfile、启动、文档、外部命令和 Lazy spec 测试全部通过。

## 风险与缓解

### 文件类型遗漏

风险：某些低频模板语言不再自动显示颜色。

缓解：保留用户命令作为显式入口；后续根据真实使用需求扩充白名单，而不是恢复全局 `"*"`。

### 加载范围与附加范围漂移

风险：`ft` 与 `opts.filetypes` 分别维护后产生不一致。

缓解：在单个 spec 文件中复用同一列表，并用测试比较最终集合。

### bigfile 清理触发插件加载

风险：清理逻辑若调用 `require`，反而会在大文件路径加载 Colorizer。

缓解：设计明确只允许读取 `package.loaded.colorizer`，并增加未加载路径测试。

### 上游 API 变化

风险：Colorizer 更改 `is_buffer_attached` 或 `detach_from_buffer`。

缓解：使用 `type(...) == "function"` 和 `pcall` 保护；API 不可用时跳过清理，不阻断 bigfile setup。
