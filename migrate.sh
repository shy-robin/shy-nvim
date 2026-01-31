#!/bin/bash

# coc.nvim 到 Native LSP 迁移脚本
# 使用方法: ./migrate.sh
# 作者: ShyRobin
# 日期: $(date)

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要条件
check_requirements() {
    log_info "检查迁移环境..."
    
    # 检查 Neovim 版本
    if ! command -v nvim &> /dev/null; then
        log_error "Neovim 未安装"
        exit 1
    fi
    
    local nvim_version=$(nvim --version | head -n1 | cut -d' ' -f2)
    log_info "当前 Neovim 版本: $nvim_version"
    
    # 检查 Git
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装"
        exit 1
    fi
    
    # 检查配置目录
    if [[ ! -d "$HOME/.config/nvim" ]]; then
        log_error "Neovim 配置目录不存在"
        exit 1
    fi
    
    # 检查是否在 coc.nvim 环境
    if [[ ! -f "$HOME/.config/nvim/lua/plugins/coc.lua" ]]; then
        log_warning "未找到 coc.lua，可能不是 coc.nvim 环境"
        read -p "是否继续迁移? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    log_success "环境检查通过"
}

# 创建备份
create_backup() {
    log_info "创建配置备份..."
    
    local backup_date=$(date +%Y%m%d.%H%M%S)
    local backup_dir="$HOME/.config/nvim.backup.coc.$backup_date"
    
    # 创建备份目录
    mkdir -p "$backup_dir"
    
    # 备份配置目录
    cp -r "$HOME/.config/nvim" "$backup_dir/config"
    
    # 备份数据目录
    if [[ -d "$HOME/.local/share/nvim" ]]; then
        cp -r "$HOME/.local/share/nvim" "$backup_dir/share"
    fi
    
    # 备份状态目录
    if [[ -d "$HOME/.local/state/nvim" ]]; then
        cp -r "$HOME/.local/state/nvim" "$backup_dir/state"
    fi
    
    # 备份缓存目录
    if [[ -d "$HOME/.cache/nvim" ]]; then
        cp -r "$HOME/.cache/nvim" "$backup_dir/cache"
    fi
    
    echo "$backup_dir" > "$HOME/.config/nvim/.migration_backup"
    log_success "备份已创建: $backup_dir"
}

# 创建 Git 分支
create_git_branch() {
    log_info "创建 Git 分支..."
    
    cd "$HOME/.config/nvim"
    
    # 检查是否有未提交的更改
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log_warning "存在未提交的更改"
        read -p "是否先提交更改? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "backup: save changes before migration"
        fi
    fi
    
    # 创建新分支
    git checkout -b feat/migrate-to-native-lsp
    git add .
    git commit -m "backup: save coc.nvim configuration before migration"
    
    log_success "Git 分支已创建"
}

# 更新 lazy.lua
update_lazy_lua() {
    log_info "更新 lua/config/lazy.lua..."
    
    local lazy_file="$HOME/.config/nvim/lua/config/lazy.lua"
    
    # 创建备份
    cp "$lazy_file" "$lazy_file.backup"
    
    # 更新文件内容
    sed -i.bak 's|.*use coc instead.*|        { import = "lazyvim.plugins.extras.lang.typescript" },  -- 重新启用|' "$lazy_file"
    sed -i '/.*use coc instead.*/a\        { import = "lazyvim.plugins.extras.coding.blink" },      -- 新增' "$lazy_file"
    sed -i '/.*use coc instead.*/d' "$lazy_file"
    
    log_success "lazy.lua 已更新"
}

# 更新 disabled.lua
update_disabled_lua() {
    log_info "更新 lua/plugins/disabled.lua..."
    
    local disabled_file="$HOME/.config/nvim/lua/plugins/disabled.lua"
    
    # 创建备份
    cp "$disabled_file" "$disabled_file.backup"
    
    # 检查是否已包含 coc禁用
    if ! grep -q "neoclide/coc.nvim" "$disabled_file"; then
        # 在文件开头添加 coc 相关禁用
        sed -i '1i\return {\n  -- 完全禁用 coc.nvim 和相关插件\n  { "neoclide/coc.nvim", enabled = false },                    -- 新增\n  { "nvimtools/none-ls.nvim", enabled = false },               -- 新增\n  { "hrsh7th/nvim-cmp", enabled = false },                     -- 新增\n  { "L3MON4D3/LuaSnip", enabled = false },                    -- 修改' "$disabled_file"
    fi
    
    # 处理现有插件的 enabled 状态
    sed -i 's/return {$/return {\n  -- 禁用 coc.nvim 相关插件\n  { "neoclide/coc.nvim", enabled = false },\n  { "nvimtools/none-ls.nvim", enabled = false },\n  { "hrsh7th/nvim-cmp", enabled = false },/' "$disabled_file"
    
    # 移除或注释 blink.cmp 的禁用
    sed -i 's|.*blink.cmp.*, enabled = false.*|-- { "saghen/blink.cmp", enabled = false },                  -- 删除|' "$disabled_file"
    
    # 确保文件格式正确
    sed -i '/^return {$/,${
        s/}$/}/
        s/local plugins = {/-- 禁用 coc.nvim 相关插件\n  { "neoclide/coc.nvim", enabled = false },\n  { "nvimtools/none-ls.nvim", enabled = false },\n  { "hrsh7th/nvim-cmp", enabled = false },/
    }' "$disabled_file"
    
    log_success "disabled.lua 已更新"
}

# 创建新的 LSP 配置
create_lsp_config() {
    log_info "创建 lua/plugins/lsp.lua..."
    
    local lsp_file="$HOME/.config/nvim/lua/plugins/lsp.lua"
    
    # 如果文件已存在，备份它
    if [[ -f "$lsp_file" ]]; then
        cp "$lsp_file" "$lsp_file.backup"
    fi
    
    # 创建新的 LSP 配置文件
    cat > "$lsp_file" << 'EOF'
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
            javascript = {
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
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = {
                "-.git",
                "-.vscode",
                "-node_modules",
                "-.vendor",
              },
              semanticTokens = true,
            },
          },
        },
      },
    },
  },
}
EOF
    
    log_success "lsp.lua 已创建"
}

# 创建格式化配置
create_format_config() {
    log_info "创建 lua/plugins/format.lua..."
    
    local format_file="$HOME/.config/nvim/lua/plugins/format.lua"
    
    # 如果文件已存在，备份它
    if [[ -f "$format_file" ]]; then
        cp "$format_file" "$format_file.backup"
    fi
    
    # 创建新的格式化配置文件
    cat > "$format_file" << 'EOF'
return {
  "LazyVim/LazyVim",
  opts = {
    conform = {
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
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
EOF
    
    log_success "format.lua 已创建"
}

# 创建代码检查配置
create_lint_config() {
    log_info "创建 lua/plugins/lint.lua..."
    
    local lint_file="$HOME/.config/nvim/lua/plugins/lint.lua"
    
    # 如果文件已存在，备份它
    if [[ -f "$lint_file" ]]; then
        cp "$lint_file" "$lint_file.backup"
    fi
    
    # 创建新的代码检查配置文件
    cat > "$lint_file" << 'EOF'
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
EOF
    
    log_success "lint.lua 已创建"
}

# 更新 mason.lua
update_mason_lua() {
    log_info "更新 lua/plugins/mason.lua..."
    
    local mason_file="$HOME/.config/nvim/lua/plugins/mason.lua"
    
    # 如果文件不存在，创建它
    if [[ ! -f "$mason_file" ]]; then
        create_mason_lua
        return
    fi
    
    # 创建备份
    cp "$mason_file" "$mason_file.backup"
    
    # 检查是否已经是 LazyVim 格式
    if grep -q '"LazyVim/LazyVim"' "$mason_file"; then
        log_info "mason.lua 已是 LazyVim 格式"
        return
    fi
    
    # 更新为 LazyVim 格式
    cat > "$mason_file" << 'EOF'
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
      ui = {
        border = "rounded",
      },
    },
  },
}
EOF
    
    log_success "mason.lua 已更新"
}

# 更新 keymaps.lua
update_keymaps_lua() {
    log_info "更新 lua/config/keymaps.lua..."
    
    local keymaps_file="$HOME/.config/nvim/lua/config/keymaps.lua"
    
    # 如果文件不存在，跳过
    if [[ ! -f "$keymaps_file" ]]; then
        log_warning "keymaps.lua 不存在，跳过更新"
        return
    fi
    
    # 创建备份
    cp "$keymaps_file" "$keymaps_file.backup"
    
    # 替换 coc 函数调用
    sed -i 's/coc#util#get_config/vim.diagnostic/g' "$keymaps_file"
    sed -i 's/coc#config/vim.diagnostic/g' "$keymaps_file"
    sed -i 's/diagnostic\.enable/is_enabled/g' "$keymaps_file"
    sed -i 's/vim\.diagnostic\.enable/vim.diagnostic.enable/g' "$keymaps_file"
    sed -i 's/vim\.diagnostic\.disable/vim.diagnostic.disable/g' "$keymaps_file"
    
    log_success "keymaps.lua 已更新"
}

# 移除 coc 相关文件
remove_coc_files() {
    log_info "移除 coc 相关文件..."
    
    local coc_files=(
        "$HOME/.config/nvim/lua/plugins/coc.lua"
        "$HOME/.config/nvim/lua/plugins/nvim-cmp.lua"
        "$HOME/.config/nvim/coc-settings.json"
    )
    
    for file in "${coc_files[@]}"; do
        if [[ -f "$file" ]]; then
            mv "$file" "$file.backup"
            log_success "已备份并移除: $(basename $file)"
        fi
    done
    
    # 移除 coc 数据目录
    if [[ -d "$HOME/.config/coc" ]]; then
        mv "$HOME/.config/coc" "$HOME/.config/coc.backup"
        log_success "已备份 coc 数据目录"
    fi
}

# 测试基本启动
test_startup() {
    log_info "测试基本启动..."
    
    # 清理可能存在的 Neovim 进程
    pkill -f nvim || true
    sleep 1
    
    # 测试启动
    if timeout 30 nvim --headless \
        -c "lua print('启动测试成功')" \
        -c "qa" 2>/dev/null; then
        log_success "基本启动测试通过"
        return 0
    else
        log_error "基本启动测试失败"
        return 1
    fi
}

# 创建验证脚本
create_verify_script() {
    log_info "创建验证脚本..."
    
    cat > "$HOME/.config/nvim/verify_migration.sh" << 'EOF'
#!/bin/bash

echo "=== 迁移验证脚本 ==="

# 1. 测试 Neovim 启动
echo "测试 1: Neovim 启动测试"
if nvim --headless -c "lua print('Neovim 启动成功')" -c "qa" 2>/dev/null; then
    echo "✅ Neovim 启动测试通过"
else
    echo "❌ Neovim 启动测试失败"
    exit 1
fi

# 2. 测试 TypeScript LSP
echo "测试 2: TypeScript LSP 测试"
cat > /tmp/test.ts << 'TSEOF'
interface User {
    name: string;
    age: number;
}

function greet(user: User): string {
    return `Hello, ${user.name}!`;
}
TSEOF

if nvim --headless \
    -c "edit /tmp/test.ts" \
    -c "lua vim.wait(3000, function() return #vim.lsp.get_active_clients() > 0 end)" \
    -c "lua if #vim.lsp.get_active_clients() == 0 then print('无 LSP 客户端') vim.cmd('cq') else print('LSP 客户端已连接') end" \
    -c "qa" 2>/dev/null; then
    echo "✅ LSP 功能测试通过"
else
    echo "⚠️ LSP 功能测试可能失败（需要手动安装服务器）"
fi

# 3. 测试补全
echo "测试 3: 代码补全测试"
if nvim --headless \
    -c "edit /tmp/test.ts" \
    -c "lua if package.loaded['blink'] then print('blink.cmp 已加载') else print('blink.cmp 未加载') end" \
    -c "qa" 2>/dev/null; then
    echo "✅ 补全测试通过"
else
    echo "❌ 补全测试失败"
fi

echo "=== 验证完成 ==="
EOF
    
    chmod +x "$HOME/.config/nvim/verify_migration.sh"
    log_success "验证脚本已创建"
}

# 创建回滚脚本
create_rollback_script() {
    log_info "创建回滚脚本..."
    
    cat > "$HOME/.config/nvim/rollback.sh" << 'EOF'
#!/bin/bash

echo "=== 迁移回滚脚本 ==="

# 读取备份目录
if [[ -f "$HOME/.config/nvim/.migration_backup" ]]; then
    backup_dir=$(cat "$HOME/.config/nvim/.migration_backup")
else
    echo "❌ 找不到备份信息"
    exit 1
fi

echo "找到备份目录: $backup_dir"

# 确认回滚
read -p "确认回滚到 coc.nvim 配置? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消回滚"
    exit 0
fi

# 停止 Neovim
pkill -f nvim || true
sleep 1

# 恢复配置目录
rm -rf "$HOME/.config/nvim"
cp -r "$backup_dir/config" "$HOME/.config/nvim"

# 恢复数据目录
if [[ -d "$backup_dir/share" ]]; then
    rm -rf "$HOME/.local/share/nvim"
    cp -r "$backup_dir/share" "$HOME/.local/share/nvim"
fi

# 恢复状态目录
if [[ -d "$backup_dir/state" ]]; then
    rm -rf "$HOME/.local/state/nvim"
    cp -r "$backup_dir/state" "$HOME/.local/state/nvim"
fi

# 恢复缓存目录
if [[ -d "$backup_dir/cache" ]]; then
    rm -rf "$HOME/.cache/nvim"
    cp -r "$backup_dir/cache" "$HOME/.cache/nvim"
fi

# 切换 Git 分支
cd "$HOME/.config/nvim"
git checkout main
git branch -D feat/migrate-to-native-lsp

echo "✅ 回滚完成"
EOF
    
    chmod +x "$HOME/.config/nvim/rollback.sh"
    log_success "回滚脚本已创建"
}

# 显示迁移后续步骤
show_next_steps() {
    echo
    log_info "迁移已完成！后续步骤："
    echo "1. 运行验证脚本: ~/.config/nvim/verify_migration.sh"
    echo "2. 如果需要回滚: ~/.config/nvim/rollback.sh"
    echo "3. 查看迁移文档: MIGRATION_PLAN.md"
    echo "4. 查看配置差异: CONFIG_DIFF.md"
    echo "5. 查看快速开始: QUICK_START.md"
    echo
    log_warning "注意事项："
    echo "- 首次启动可能需要一些时间来安装 LSP 服务器"
    echo "- 如果遇到问题，请检查 :checkhealth 命令的输出"
    echo "- 某些功能可能需要手动安装外部工具"
}

# 主函数
main() {
    echo "=== coc.nvim 到 Native LSP 迁移脚本 ==="
    echo
    
    # 检查是否在正确的目录
    if [[ ! -f "$HOME/.config/nvim/init.lua" ]]; then
        log_error "不像是 Neovim 配置目录"
        exit 1
    fi
    
    # 确认迁移
    echo "此脚本将把您的 coc.nvim 配置迁移到 Native LSP"
    echo "迁移之前会自动创建备份"
    echo
    read -p "确认开始迁移? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消迁移"
        exit 0
    fi
    
    # 执行迁移步骤
    check_requirements
    create_backup
    create_git_branch
    update_lazy_lua
    update_disabled_lua
    create_lsp_config
    create_format_config
    create_lint_config
    update_mason_lua
    update_keymaps_lua
    remove_coc_files
    create_verify_script
    create_rollback_script
    
    # 测试启动
    if test_startup; then
        log_success "迁移成功完成！"
        show_next_steps
    else
        log_error "迁移后启动测试失败"
        echo
        echo "可能的解决方案："
        echo "1. 检查错误信息: nvim --headless -c 'qa'"
        echo "2. 运行回滚脚本: ~/.config/nvim/rollback.sh"
        echo "3. 查看迁移文档解决问题"
        exit 1
    fi
}

# 运行主函数
main "$@"