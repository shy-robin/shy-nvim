# coc.nvim 到 Native LSP 迁移计划

## 概述

本文档详细描述了从 coc.nvim 迁移到 Native LSP 的完整计划，确保迁移前后功能不受影响。迁移将基于 LazyVim 的现代化插件生态系统，包括 blink.cmp、conform.nvim 等最新插件。

## 迁移目标

- 保持所有现有功能可用
- 提升性能和稳定性
- 简化配置管理
- 与 LazyVim 生态系统保持一致

## 功能对比清单

### 1. 代码补全 (Code Completion)

| coc.nvim 功能 | Native LSP 替代方案 | 验证方式 |
|---------------|-------------------|----------|
| 基础代码补全 | blink.cmp + LSP | 测试各种文件类型的补全 |
| 片段补全 | blink.cmp + LuaSnip | 测试片段触发和跳转 |
| 路径补全 | blink.cmp path source | 测试文件路径补全 |
| 缓冲区补全 | blink.cmp buffer source | 测试当前缓冲区词补全 |

### 2. 代码导航 (Code Navigation)

| coc.nvim 功能 | Native LSP 替代方案 | 验证方式 |
|---------------|-------------------|----------|
| 跳转到定义 (gd) | vim.lsp.buf.definition | 测试函数/变量定义跳转 |
| 跳转到类型定义 (gy) | vim.lsp.buf.type_definition | 测试类型定义跳转 |
| 跳转到实现 (gi) | vim.lsp.buf.implementation | 测试接口/实现跳转 |
| 查找引用 (gr) | vim.lsp.buf.references | 测试查找所有引用 |
| 悬停文档 (K) | vim.lsp.buf.hover | 测试显示悬停信息 |

### 3. 代码格式化 (Code Formatting)

| coc.nvim 功能 | Native LSP 替代方案 | 验证方式 |
|---------------|-------------------|----------|
| 保存时格式化 | conform.nvim | 测试各语言文件保存格式化 |
| 手动格式化格式化 | conform.nvim | 测试 <leader>cf 命令 |
| 格式化选中区域 | conform.nvim | 测试区域格式化功能 |

### 4. 代码检查与诊断

| coc.nvim 功能 | Native LSP 替代方案 | 验证方式 |
|---------------|-------------------|----------|
| 实时检查 | nvim-lint + LSP 诊断 | 测试语法错误检测 |
| 添加修复 | nvim-lint + LSP | 测试自动修复功能 |
| 导航诊断 | vim.diagnostic.* 函数 | 测试诊断导航 |

### 5. 代码重构

| coc.nvim 功能 | Native LSP 替代方案 | 验证方式 |
|---------------|-------------------|----------|
| 重命名符号 | vim.lsp.buf.rename | 测试变量/函数重命名 |
| 代码动作 | vim.lsp.buf.code_action | 测试导入排序等代码动作 |
| 提取方法/变量 | LSP code actions | 测试重构操作 |

### 6. 语言特定功能

#### TypeScript/JavaScript

| coc.nvim 扩展 | Native LSP 替代 | 验证测试 |
|---------------|----------------|----------|
| coc-tsserver | typescript-tools | TS 类型检查、补全 |
| coc-volar | volar | Vue 3 支持 |
| coc-prettier | conform.nvim + prettierd | Prettier 格式化 |
| coc-eslint | nvim-lint + eslint_d | ESLint 诊断 |

#### Lua

| coc.nvim 扩展 | Native LSP 替代 | 验证测试 |
|---------------|----------------|----------|
| coc-lua | lua_ls | Lua 类型提示 |
| coc-stylua | conform.nvim + stylua | Lua 格式化 |

## 迁移前准备

### 1. 备份现有配置

```bash
# 创建完整备份
cp -r ~/.config/nvim ~/.config/nvim.backup.coc.$(date +%Y%m%d.%H%M%S)
cp -r ~/.local/share/nvim ~/.local/share/nvim.backup.coc.$(date +%Y%m%d.%H%M%S)
cp -r ~/.local/state/nvim ~/.local/state/nvim.backup.coc.$(date +%Y%m%d.%H%M%S)
cp -r ~/.cache/nvim ~/.cache/nvim.backup.coc.$(date +%Y%m%d.%H%M%S)

# 创建 Git 分支
cd ~/.config/nvim
git checkout -b feat/migrate-to-native-lsp
git add .
git commit -m "backup: save coc.nvim configuration before migration"
```

### 2. 创建测试环境

```bash
# 创建测试目录
mkdir -p ~/nvim-migration-test
cd ~/nvim-migration-test

# 克隆配置到测试环境
git clone ~/.config/nvim test-nvim
cd test-nvim

# 创建独立的 Neovim 数据目录
export NVIM_DATA_DIR="$HOME/nvim-migration-test/data"
mkdir -p $NVIM_DATA_DIR
```

### 3. 安装必要依赖

```bash
# 确保以下工具已安装
npm install -g typescript-language-server
npm install -g typescript-tools-language-server
npm install -g prettierd
npm install -g eslint_d

# 检查 Rust 工具链（如需使用 blink.cmp 主分支）
rustc --version
cargo --version
```

## 迁移步骤清单

### 第一阶段：基础插件迁移

#### 1. 更新 lazy.lua 配置

```lua
-- lua/config/lazy.lua
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
  }
}
```

#### 2. 禁用 coc.nvim 相关插件

```lua
-- lua/plugins/disabled.lua
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

#### 3. 测试基础功能

```bash
NVIM_APPNAME=test-nvim nvim --headless \
  -c "lua print('Testing basic setup')" \
  -c "qa"

# 检查是否有启动错误
echo $?
```

### 第二阶段：LSP 配置迁移

#### 1. 创建现代化 LSP 配置

```lua
-- lua/plugins/lsp.lua
return {
  "LazyVim/LazyVim",
  opts = {
    -- LazyVim 的 LSP 配置
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

#### 2. 配置代码格式化

```lua
-- lua/plugins/conform.lua
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

#### 3. 配置代码检查

```lua
-- lua/plugins/lint.lua
return {
  "LazyVim/LazyVim",
  opts = {
    lint = {
      linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },
        markdown = { "markdownlint" },
        python = { "ruff" },
        sh = { "shellcheck" },
      },
    },
  },
}
```

#### 4. 配置 Mason

```lua
-- lua/plugins/mason.lua
return {
  "LazyVim/LazyVim",
  opts = {
    mason = {
      ensure_installed = {
        "typescript-tools",
        "lua-language-server",
        "vue-language-server",
        "prettierd",
        "eslint_d",
        "stylua",
        "markdownlint-cli2",
        "ruff",
      },
    },
  },
}
```

### 第三阶段：功能验证

#### 1. 设置验证脚本

```bash
# 创建迁移验证脚本
cat > ~/nvim-migration-test/verify.sh << 'EOF'
#!/bin/bash

CONFIG_DIR="$HOME/nvim-migration-test/config"
TEST_PROJECT="$HOME/nvim-migration-test/test-project"

echo "=== 迁移验证脚本 ==="

# 1. 创建测试项目
mkdir -p "$TEST_PROJECT"
cd "$TEST_PROJECT"

# 创建基本的 package.json
cat > package.json << 'PACKAGEEOF'
{
  "name": "test-migration",
  "version": "1.0.0",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "prettier": "^3.0.0",
    "eslint": "^8.0.0"
  }
}
PACKAGEEOF

# 创建测试 TypeScript 文件
cat > test.ts << 'TSEOF'
interface User {
  name: string;
  age: number;
}

function greet(user: User): string {
  return `Hello, ${user.name}!`;
}

const user: User = { name: "World", age: 42 };
const message = greet(user);
console.log(message);
TSEOF

# 2. 测试 Neovim 启动
echo "测试 1: Neovim 启动测试"
NVIM_APPNAME=test-nvim nvim --headless \
  -c "lua print('Neovim 启动成功')" \
  -c "qa" 2>&1

if [ $? -eq 0 ]; then
  echo "✅ Neovim 启动测试通过"
else
  echo "❌ Neovim 启动测试失败"
  exit 1
fi

# 3. 测试 LSP 功能
echo "测试 2: LSP 功能测试"
NVIM_APPNAME=test-nvim nvim --headless \
  -c "edit test.ts" \
  -c "lua vim.wait(2000, function() return #vim.lsp.get_active_clients() > 0 end)" \
  -c "lua if #vim.lsp.get_active_clients() == 0 then print('无 LSP 客户端') vim.cmd('cq') else print('LSP 客户端已连接') end" \
  -c "qa" 2>&1

if [ $? -eq 0 ]; then
  echo "✅ LSP 功能测试通过"
else
  echo "❌ LSP 功能测试失败"
  exit 1
fi

echo "=== 验证完成 ==="
EOF

chmod +x ~/nvim-migration-test/verify.sh
```

#### 2. 功能检查清单

| 功能 | 测试命令 | 预期结果 |
|------|----------|----------|
| 基础启动 | `nvim --headless -c "qa"` | 无错误 |
| LSP 连接 | 手动打开 TS 文件 | LSP 客户端自动连接 |
| 代码补全 | 插入模式下编辑代码 | 触发补全菜单 |
| 代码格式化 | 保存 TS 文件 | 自动格式化 |
| 诊断显示 | 故意写错代码 | 显示错误提示 |
| 代码导航 | gd 跳转定义 | 正确跳转到定义处 |
| 代码动作 | <leader>ca | 显示可用的代码动作 |

### 第四阶段：快捷键和 UI 调整

#### 1. 更新快捷键映射

```lua
-- lua/plugins/which-key.lua
local wk = require("which-key")

-- 移除 coc 相关分组
wk.remove({ "<leader>", "c" }, { mode = "n", group = "+coc" })

-- 添加新的 LSP 分组
wk.add({
  { "<leader>c", group = "Code" },
  { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" } },
  { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
  { "<leader>cf", function() require("conform").format() end, desc = "Format" },
  { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
  { "gr", vim.lsp.buf.references, desc = "References" },
  { "gi", vim.lsp.buf.implementation, desc = "Goto Implementation" },
  { "gy", vim.lsp.buf.type_definition, desc = "Goto Type Definition" },
  { "K", vim.lsp.buf.hover, desc = "Hover" },
  { "[d", vim.diagnostic.goto_prev, desc = "Prev Diagnostic" },
  { "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
})
```

#### 2. 更新 UI 相关插件

```lua
-- lua/plugins/lualine.lua
return {
  "nvim-lualine/lualine",
  opts = function()
    local config = require("lualine").get_config()
    
    -- 更新状态栏组件
    table.insert(config.sections.lualine_x, {
      function()
        return "LSP:" .. (#vim.lsp.get_active_clients() > 0 and "✓" or "✗")
      end,
    })
    
    return config
  end,
}
```

## 回滚计划

### 1. 回滚触发条件

- LSP 服务器无法连接
- 代码补全功能异常
- 格式化功能失效
- 性能显著下降
- 关键快捷键失效

### 2. 回滚步骤

```bash
# 1. 停止 Neovim
pkill -f nvim

# 2. 恢复备份配置
rm -rf ~/.config/nvim
cp -r ~/.config/nvim.backup.coc.YYYYMMDD.HHMMSS ~/.config/nvim

# 3. 恢复数据目录
rm -rf ~/.local/share/nvim
cp -r ~/.local/share/nvim.backup.coc.YYYYMMDD.HHMMSS ~/.local/share/nvim

# 4. 切换 Git 分支
cd ~/.config/nvim
git checkout main
git branch -D feat/migrate-to-native-lsp

# 5. 验证回滚
nvim --headless -c "lua print('回滚成功')" -c "qa"
```

### 3. 回滚验证清单

| 功能 | 验证方法 | 预期结果 |
|------|----------|----------|
| coc.nvim 启动 | 打开 nvim | coc 进程运行 |
| 代码补全 | 编辑代码 | coc 补全菜单 |
| LSP 功能 | :CocCommand diagnostics | 显示诊断信息 |
| 格式化 | 保存文件 | 自动格式化 |

## 测试验证清单

### 1. 自动化测试

```bash
# 运行验证脚本
~/nvim-migration-test/verify.sh
```

### 2. 手动测试项目

创建以下测试项目来验证功能：

#### TypeScript/React 项目
```bash
mkdir -p ~/test-projects/react-ts
cd ~/test-projects/react-ts

# 创建基本项目结构
npx create-react-app . --template typescript
```

#### Vue 3 项目
```bash
mkdir -p ~/test-projects/vue3
cd ~/test-projects/vue3

# 创建基本项目结构
npm create vue@latest .
```

#### Node.js 项目
```bash
mkdir -p ~/test-projects/node-ts
cd ~/test-projects/node-ts

# 初始化项目
npm init -y
npm install typescript @types/node --save-dev
```

### 3. 功能测试清单

| 测试项目 | 测试文件 | 验证功能 | 预期结果 |
|---------|----------|----------|----------|
| React-TS | App.tsx | TS 类型检查 | 类型错误正确提示 |
| React-TS | App.tsx | 代码补全 | React API 补全 |
| Vue 3 | App.vue | Vue 支持 | Vue 特性补全 |
| Vue 3 | App.vue | 模板语法 | 模板语法高亮 |
| Node-TS | index.ts | Node.js API | Node API 补全 |
| Node-TS | index.ts | ES 模块 | 模块导入正确处理 |

### 4. 性能测试

```bash
# 创建性能测试脚本
cat > ~/nvim-migration-test/performance-test.sh << 'EOF'
#!/bin/bash

echo "=== 性能测试 ==="

# 测试启动时间
echo "测试启动时间..."
time nvim --headless -c "qa" 2>&1

# 测试大文件处理
echo "测试大文件处理..."
dd if=/dev/zero of=/tmp/test-large.js bs=1M count=10
time nvim --headless \
  -c "edit /tmp/test-large.js" \
  -c "normal G" \
  -c "qa" 2>&1

# 测试补全速度
echo "测试补全速度..."
cat > /tmp/test-completion.js << 'JSEOF'
const veryLongVariableNameToTestCompletion = 'test';
const anotherVeryLongVariableNameToTestCompletion = 'test2';

JSEOF

time nvim --headless \
  -c "edit /tmp/test-completion.js" \
  -c "normal 2Govery" \
  -c "lua vim.wait(1000)" \
  -c "qa" 2>&1

echo "=== 性能测试完成 ==="
EOF

chmod +x ~/nvim-migration-test/performance-test.sh
```

## 迁移后优化

### 1. 性能优化

```lua
-- lua/config/options.lua
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 50

-- 延迟加载大型插件
vim.loader.enable()
```

### 2. 用户体验优化

```lua
-- lua/plugins/blink.lua (如果需要额外配置)
return {
  "saghen/blink.cmp",
  opts = {
    -- 优化性能的配置
    completion = {
      menu = {
        draw = {
          treesitter = { "lsp" },
        },
      },
    },
    -- 减少不必要的更新
    keyword = {
      range = "full",
    },
  },
}
```

### 3. 监控和维护

```lua
-- lua/plugins/health.lua
return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = {
          enabled = false, -- 减少不必要的进度更新
        },
      },
    },
  },
}
```

## 总结

本迁移计划确保了从 coc.nvim 到 Native LSP 的平滑过渡，通过详细的步骤和验证机制，保证迁移前后功能不受影响。迁移完成后，您将获得：

- 更轻量、更快的编辑体验
- 更好的可维护性和扩展性
- 与 LazyVim 生态系统的良好集成
- 更现代化的插件支持

如果在迁移过程中遇到问题，可以随时使用回滚计划恢复到 coc.nvim 配置。