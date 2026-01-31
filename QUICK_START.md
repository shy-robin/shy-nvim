# 迁移快速开始指南

本指南帮助您快速开始从 coc.nvim 迁移到 Native LSP。

## 🚀 快速迁移步骤

### 1. 准备工作 (5分钟)

```bash
# 1. 创建备份
cp -r ~/.config/nvim ~/.config/nvim.backup.coc.$(date +%Y%m%d.%H%M%S)

# 2. 创建测试分支
cd ~/.config/nvim
git checkout -b feat/migrate-to-native-lsp
git add .
git commit -m "backup: save coc.nvim configuration before migration"
```

### 2. 基础配置更改 (10分钟)

#### 2.1 更新 `lua/config/lazy.lua`

```lua
return {
  spec = {
    -- 添加 LazyVim 和导入它的插件
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    
    -- 启用 LazyVim extras
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.coding.blink" },
    
    -- 导入/覆盖您的插件
    { import = "plugins" },
  },
}
```

#### 2.2 更新 `lua/plugins/disabled.lua`

```lua
return {
  -- 禁用 coc.nvim 及相关插件
  { "neoclide/coc.nvim", enabled = false },
  { "nvimtools/none-ls.nvim", enabled = false },
  { "hrsh7th/nvim-cmp", enabled = false },
  { "L3MON4D3/LuaSnip", enabled = false },
  
  -- 禁用与 LazyVim 冲突的插件
  { "nvim-mini/mini.pairs", enabled = false },
  { "linrongbin16/lsp-progress.nvim", enabled = false },
  { "mfussenegger/nvim-lint", enabled = false },
  { "LunarVim/bigfile.nvim", enabled = false },
  { "luukvbaal/statuscol.nvim", enabled = false },
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
}
```

### 3. 第一次测试 (5分钟)

```bash
# 测试基础启动
nvim --headless -c "lua print('基础启动测试')" -c "qa"

# 如果启动成功，继续下一步
# 如果失败，检查错误信息并回滚
```

### 4. 创建新的 LSP 配置 (10分钟)

创建 `lua/plugins/lsp.lua`：

```lua
return {
  "LazyVim/LazyVim",
  opts = {
    lsp = {
      servers = {
        typescript_tools = {
          enabled = true,
          settings = {
            typescript = {
              preferences = {
                includeInlayParameterNameHints = "all",
                includeInlayVariableTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        volar = {
          enabled = true,
          filetypes = { "vue" },
        },
      },
    },
  },
}
```

### 5. 格式化和检查配置 (5分钟)

创建 `lua/plugins/format.lua`：

```lua
return {
  "LazyVim/LazyVim",
  opts = {
    conform = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        python = { "black", "isort", stop_after_first = true },
        go = { "gofumpt", "goimports" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
}
```

### 6. 测试基本功能 (10分钟)

1. **启动测试**：打开一个 TypeScript 文件，检查是否自动加载 LSP
2. **补全测试**：尝试输入 `console.` 看是否有补全
3. **格式化测试**：保存文件，检查是否自动格式化
4. **诊断测试**：故意写一个错误，检查是否显示错误提示

## 📋 功能验证清单

### 基础功能验证

- [ ] Neovim 正常启动
- [ ] TypeScript 文件自动加载 LSP
- [ ] 代码补全正常工作
- [ ] 保存时自动格式化
- [ ] 语法错误显示
- [ ] 跳转定义 (gd) 正常工作
- [ ] 查找引用 (gr) 正常工作
- [ ] 代码重命名 (<leader>cr) 正常工作

### 高级功能验证

- [ ] Vue 3 项目支持
- [ ] Lua 配置文件支持
- [ ] Python 项目支持
- [ ] Go 项目支持
- [ ] 代码片段正常工作
- [ ] UI 正常显示
- [ ] 快捷键正常工作

## 🔧 常见问题解决

### 问题 1: LSP 服务器无法连接

**解决方案**：
```bash
# 检查是否安装了 LSP 服务器
nvim --headless -c "Mason" -c "qa"

# 手动安装 TypeScript 服务器
:MasonInstall typescript-tools
:MasonInstall vue-language-server
```

### 问题 2: 代码补全不工作

**解决方案**：
```lua
-- 检查 blink.cmp 配置
:lua print(vim.inspect(require("blink.cmp").get_config()))

# 重启 Neovim
:qa
```

### 问题 3: 格式化不工作

**解决方案**：
```bash
# 检查是否安装了格式化工具
which prettierd
which stylua

# 手动安装
:MasonInstall prettierd
:MasonInstall stylua
```

### 问题 4: 性能问题

**解决方案**：
```lua
-- 添加到 lua/config/options.lua
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300

-- 启用延迟加载
vim.loader.enable()
```

## 🔄 回滚方案

如果迁移过程中遇到无法解决的问题，可以快速回滚：

```bash
# 1. 停止 Neovim
pkill -f nvim

# 2. 恢复配置
rm -rf ~/.config/nvim
cp -r ~/.config/nvim.backup.coc.YYYYMMDD.HHMMSS ~/.config/nvim

# 3. 切换分支
cd ~/.config/nvim
git checkout main
git branch -D feat/migrate-to-native-lsp
```

## 📞 获取帮助

1. **查看详细迁移计划**：`MIGRATION_PLAN.md`
2. **检查 LazyVim 文档**：https://www.lazyvim.org/
3. **社区支持**：LazyVim GitHub Discussions

## 🎯 下一步

迁移完成后，您可以：

1. 自定义 LSP 配置以适应您的需求
2. 添加更多语言支持
3. 优化性能和用户体验
4. 探索 LazyVim 的其他功能

祝您迁移顺利！🚀