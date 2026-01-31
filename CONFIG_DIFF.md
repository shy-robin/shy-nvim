# 迁移配置差异对比

本文档详细对比了迁移前后的配置差异，帮助你快速了解需要更改的内容。

## 📋 配置文件修改清单

### 1. `lua/config/lazy.lua`

#### 迁移前 (coc.nvim)
```lua
return {
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    -- use coc instead
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.coding.neogen" },
    { import = "lazyvim.plugins.extras.editor.harpoon2" },
    { import = "lazyvim.plugins.extras.util.rest" },
    { import = "lazyvim.plugins.extras.editor.outline" },
    -- { import = "lazyvim.plugins.extras.coding.yanky" },
    -- import/override with your plugins
    { import = "plugins" },
  },
}
```

#### 迁移后 (Native LSP)
```lua
return {
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.typescript" },  -- 重新启用
    { import = "lazyvim.plugins.extras.coding.blink" },      -- 新增
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.coding.neogen" },
    { import = "lazyvim.plugins.extras.editor.harpoon2" },
    { import = "lazyvim.plugins.extras.util.rest" },
    { import = "lazyvim.plugins.extras.editor.outline" },
    -- import/override with your plugins
    { import = "plugins" },
  },
}
```

**主要变更**：
- ✅ 启用 `lazyvim.plugins.extras.lang.typescript`
- ✅ 新增 `lazyvim.plugins.extras.coding.blink`

---

### 2. `lua/plugins/disabled.lua`

#### 迁移前
```lua
local plugins = {
  "nvimtools/none-ls.nvim",
  "goolord/alpha-nvim",
  "RRethy/vim-illuminate",
  -- "mason-org/mason.nvim",
  "mason-org/mason-lspconfig.nvim",
  "hrsh7th/nvim-cmp",
  "neovim/nvim-lspconfig",
  -- 禁用这个插件，使用 coc-pair
  "nvim-mini/mini.pairs",
  -- use coc-snippets instead
  -- coc 不支持 LuaSnip (https://github.com/neoclide/coc.nvim/discussions/4477)
  "L3MON4D3/LuaSnip",
  "linrongbin16/lsp-progress.nvim",
  -- use vim native operations instead
  -- see: https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
  "mg979/vim-visual-multi",
  -- use nvim-tree instead
  "nvim-neo-tree/neo-tree.nvim",
  -- use picker in nvim-tree instead
  "s1n7ax/nvim-window-picker",
  -- "kevinhwang91/nvim-ufo",
  -- 初始化会报错缺少依赖，先禁用这个插件
  "rest-nvim/rest.nvim",
  "folke/trouble.nvim",
  -- 使用 coc-markdown-preview-enhanced 代替
  -- "iamcco/markdown-preview.nvim",
  "mfussenegger/nvim-lint",
  -- 使用 LazyVim 提供的 Snacks.dashboard
  "nvimdev/dashboard-nvim",
  -- 使用 LazyVim 提供的 Snacks.bigfile
  "LunarVim/bigfile.nvim",
  -- 使用 LazyVim 提供的 Snacks.statuscolumn
  "luukvbaal/statuscol.nvim",
  -- 使用 LazyVim 提供的 Snacks.indent-blankline
  "lukas-reineke/indent-blankline.nvim",
  -- 与 coc 冲突，暂时禁用
  "saghen/blink.cmp",
  -- 使用 fzf.lua 代替
  "nvim-telescope/telescope.nvim",
  -- 使用 fzf.lua 代替
  "nvim-telescope/telescope-file-browser.nvim",
  -- "HakonHarnes/img-clip.nvim",
  "kevinhwang91/nvim-ufo",
  -- 暂时禁用（使用 opencode）
  "yetone/avante.nvim",
  "Kurama622/llm.nvim",
}

local disabled_plugins = {}

for _, value in pairs(plugins) do
  table.insert(disabled_plugins, {
    value,
    enabled = false,
  })
end

return disabled_plugins
```

#### 迁移后
```lua
return {
  -- 完全禁用 coc.nvim 和相关插件
  { "neoclide/coc.nvim", enabled = false },                    -- 新增
  { "nvimtools/none-ls.nvim", enabled = false },               -- 新增
  { "hrsh7th/nvim-cmp", enabled = false },                     -- 新增
  { "L3MON4D3/LuaSnip", enabled = false },                    -- 修改
  { "nvim-mini/mini.pairs", enabled = false },                -- 修改
  { "linrongbin16/lsp-progress.nvim", enabled = false },      -- 修改
  { "mfussenegger/nvim-lint", enabled = false },              -- 修改
  { "LunarVim/bigfile.nvim", enabled = false },               -- 修改
  { "luukvbaal/statuscol.nvim", enabled = false },            -- 修改
  { "lukas-reineke/indent-blankline.nvim", enabled = false }, -- 修改
  -- 移除 blink.cmp 的禁用（现在需要启用它）
  -- { "saghen/blink.cmp", enabled = false },                  -- 删除
  
  -- 其他保持禁用的插件
  { "goolord/alpha-nvim", enabled = false },
  { "RRethy/vim-illuminate", enabled = false },
  { "mg979/vim-visual-multi", enabled = false },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  { "s1n7ax/nvim-window-picker", enabled = false },
  { "rest-nvim/rest.nvim", enabled = false },
  { "folke/trouble.nvim", enabled = false },
  { "nvimdev/dashboard-nvim", enabled = false },
  { "nvim-telescope/telescope.nvim", enabled = false },
  { "nvim-telescope/telescope-file-browser.nvim", enabled = false },
  { "kevinhwang91/nvim-ufo", enabled = false },
  { "yetone/avante.nvim", enabled = false },
  { "Kurama622/llm.nvim", enabled = false },
}
```

**主要变更**：
- ✅ 新增 `neoclide/coc.nvim` 禁用
- ✅ 将部分禁用插件改为 `enabled = false` 格式
- ✅ 删除 `saghen/blink.cmp` 的禁用

---

### 3. `lua/plugins/lspconfig.lua` (新增)

#### 迁移后 (新文件)
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
          settings = {
            typescript = {
              tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
    },
  },
}
```

---

### 4. `lua/plugins/format.lua` (新增)

#### 迁移后 (新文件)
```lua
return {
  "LazyVim/LazyVim",
  opts = {
    conform = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        graphql = { "prettierd", "prettier", stop_after_first = true },
        python = { "black", "isort", stop_after_first = true },
        go = { "gofumpt", "goimports" },
        rust = { "rustfmt" },
        sql = { "sqlfmt" },
        sh = { "shfmt" },
      },
      formatters = {
        prettierd = {
          condition = function(ctx)
            return vim.fs.find({
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.yml",
              ".prettierrc.yaml",
              ".prettierrc.json5",
              ".prettierrc.js",
              ".prettierrc.cjs",
              "prettier.config.js",
              "prettier.config.cjs",
            }, { path = ctx.filename, upward = true })[1]
          end,
        },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
}
```

---

### 5. `lua/plugins/lint.lua` (新增)

#### 迁移后 (新文件)
```lua
return {
  "LazyVim/LazyVim",
  opts = {
    lint = {
      linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },
        markdown = { "markdownlint" },
        python = { "ruff" },
        go = { "golangci-lint" },
        sh = { "shellcheck" },
        dockerfile = { "hadolint" },
      },
      linters = {
        eslint_d = {
          condition = function(ctx)
            return vim.fs.find({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.json",
              ".eslintrc.yml",
              ".eslintrc.yaml",
              "package.json",
            }, { path = ctx.filename, upward = true })[1]
          end,
        },
      },
    },
  },
}
```

---

### 6. `lua/plugins/mason.lua` (更新)

#### 迁移前
```lua
return {
  "mason-org/mason.nvim",
  opts = {
    -- 自动安装 lsp
    ensure_installed = {
      -- "stylua",
      -- "shfmt",
      -- "vue-language-server",
      -- "html-lsp",
      -- "css-lsp",
      -- "svelte-language-server",
      -- "prettierd",
      -- "eslint_d",
      -- emmet-ls 存在一些问题：
      -- https://github.com/aca/emmet-ls/issues/42
      -- "emmet-language-server"
    },
    ui = {
      border = "rounded"
    }
  },
}
```

#### 迁移后
```lua
return {
  "LazyVim/LazyVim",
  opts = {
    mason = {
      ensure_installed = {
        -- LSP servers
        "typescript-tools",
        "vue-language-server",
        "lua-language-server",
        "json-lsp",
        "yaml-language-server",
        "html-lsp",
        "css-lsp",
        "svelte-language-server",
        "pyright",
        "ruff",
        "gopls",
        "rust-analyzer",
        "tailwindcss-language-server",
        "emmet-language-server",
        
        -- Formatters
        "prettierd",
        "stylua",
        "black",
        "isort",
        "gofumpt",
        "rustfmt",
        "sqlfmt",
        "shfmt",
        
        -- Linters
        "eslint_d",
        "markdownlint-cli2",
        "shellcheck",
        "golangci-lint",
        "hadolint",
        
        -- Debuggers
        "debugpy",
        "delve",
        
        -- DAP adapters
        "codelldb",
      },
    },
  },
}
```

**主要变更**：
- ✅ 使用 LazyVim 的配置方式
- ✅ 添加完整的工具列表

---

### 7. `lua/plugins/coc.lua` (删除)

#### 迁移前
```lua
return {
  "neoclide/coc.nvim",
  branch = "release",
  event = "VeryLazy",
  -- ... 大量 coc 配置 ...
}
```

#### 迁移后
```lua
-- 文件已删除
```

**主要变更**：
- ✅ 完全删除 coc.lua 文件

---

### 8. `lua/plugins/nvim-cmp.lua` (删除)

#### 迁移前
```lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-cmdline",
    "f3fora/cmp-spell"
  },
  -- ... nvim-cmp 配置 ...
}
```

#### 迁移后
```lua
-- 文件已删除
```

**主要变更**：
- ✅ 完全删除 nvim-cmp.lua 文件

---

### 9. `lua/config/keymaps.lua` (更新)

#### 迁移前 (部分)
```lua
-- 使用 coc 的能力进行重写
return {
  toggle_diagnostic = function()
    return vim.fn["coc#util#get_config"]("diagnostic").enable
  end,
  toggle_diagnostic_on = function()
    vim.fn["coc#config"]("diagnostic.enable", true)
  end,
  toggle_diagnostic_off = function()
    vim.fn["coc#config"]("diagnostic.enable", false)
  end,
  -- ... 其他 coc 相关函数 ...
}
```

#### 迁移后
```lua
-- 使用 Native LSP 的能力
return {
  toggle_diagnostic = function()
    return vim.diagnostic.is_enabled()
  end,
  toggle_diagnostic_on = function()
    vim.diagnostic.enable()
  end,
  toggle_diagnostic_off = function()
    vim.diagnostic.disable()
  end,
  -- ... 其他 Native LSP 相关函数 ...
}
```

**主要变更**：
- ✅ 替换 coc 函数调用为 Native LSP 函数

---

## 🎯 功能映射对照表

| coc.nvim 功能 | Native LSP 功能 | 配置变更 |
|---------------|----------------|----------|
| `coc#config` | `vim.diagnostic.*` | keymaps.lua |
| `CocAction` | `vim.lsp.buf.*` | keymaps.lua |
| `coc#float` | `vim.diagnostic.open_float` | keymaps.lua |
| `coc#refresh` | blink.cmp 自动触发 | 无需配置 |
| `coc-snippets` | LuaSnip (LazyVim 内置) | 无需配置 |
| `coc-marketplace` | Mason UI | 无需配置 |
| `coc-format` | conform.nvim | format.lua |
| `coc-eslint` | nvim-lint | lint.lua |
| `coc-tsserver` | typescript-tools | lsp.lua |
| `coc-volar` | volar | lsp.lua |

---

## 📊 迁移影响分析

### 需要删除的文件
- `lua/plugins/coc.lua`
- `lua/plugins/nvim-cmp.lua`

### 需要更新的文件
- `lua/config/lazy.lua`
- `lua/plugins/disabled.lua`
- `lua/plugins/mason.lua`
- `lua/config/keymaps.lua`

### 需要新增的文件
- `lua/plugins/lsp.lua` (或更新现有的 lspconfig.lua)
- `lua/plugins/format.lua`
- `lua/plugins/lint.lua`

### 保持不变的文件
- `lua/plugins/telescope.lua`
- `lua/plugins/nvim-tree.lua`
- `lua/plugins/gitsigns.lua`
- `lua/plugins/treesitter.lua`
- 其他非 LSP 相关配置

---

## 🔍 迁移检查清单

### 迁移前检查
- [ ] 备份所有配置文件
- [ ] 创建 Git 分支
- [ ] 确认当前功能正常工作

### 迁移中检查
- [ ] 每修改一个文件后启动测试
- [ ] 检查是否有启动错误
- [ ] 验证基本功能不丢失

### 迁移后检查
- [ ] 测试所有语言的 LSP 功能
- [ ] 测试代码补全和导航
- [ ] 测试代码格式化
- [ ] 测试代码检查
- [ ] 测试所有自定义快捷键

---

这个配置差异对比帮助您清晰了解迁移的具体变更，确保不会遗漏任何重要步骤。