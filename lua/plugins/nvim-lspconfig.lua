-- 避免一个文件有多个 lsp 格式化冲突
-- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      -- apply whatever logic you want (in this example, we'll only use diagnosticls)
      return client.name == "diagnosticls"
    end,
    bufnr = bufnr,
  })
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- add to your shared on_attach callback
local formatting_callback = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
    })
  end
end

-- 绑定 EslintFixAll 的快捷键
local bind_eslint_fix_all = function(bufnr)
  vim.keymap.set("n", "<leader>fe", function()
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local cmd = string.format('eslint_d --fix %s', filepath)
    vim.fn.system(cmd)
  end, { desc = "Eslint Fix All" })
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    capabilities = {
      -- Tell the server the capability of foldingRange,
      -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
      -- https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        }
      }
    },
    diagnostics = {
      virtual_text = {
        -- 显示诊断的来源，如 eslint
        source = true,
      },
      float = {
        border = "rounded",
        -- suffix = function(diagnostic)
        --   return string.format(" %s[%s]", diagnostic.source, diagnostic.code)
        -- end,
        source = true,
      },
    },
    autoformat = true,
    format_notify = false,
    -- 这里声明的 server 会自动安装，作用和 mason.lua 里的配置相同
    servers = {
      volar = {
        -- 开启 takeover 模式（在 js 或 ts 文件使用 volar）
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
      },
      -- 自定义代码诊断 lsp
      -- 在这里配置 linter 和 formatter
      diagnosticls = {
        on_attach = function(client, bufnr)
          -- 当一个 buffer 同时有多个 lsp 开启时，多个 lsp 的格式化程序可能会冲突；
          -- https://github.com/neovim/nvim-lspconfig/wiki/Multiple-language-servers-FAQ
          formatting_callback(client, bufnr)
          bind_eslint_fix_all(bufnr)
        end,
        -- 指定开启 diagnosticls 的文件类型
        filetypes = {
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "html",
          "css",
          "less",
          "scss",
          "vue"
        },
        init_options = {
          -- 指定不同文件类型使用的 linter
          filetypes = {
            javascript = "eslint",
            typescript = "eslint",
            javascriptreact = "eslint",
            typescriptreact = "eslint",
            html = "eslint",
            css = "eslint",
            less = "eslint",
            scss = "eslint",
            vue = "eslint",
          },
          linters = {
            eslint = {
              -- 诊断显示的来源名称
              sourceName = "EsLint",
              -- 使用 eslint_d，提供更好的性能
              command = "eslint_d",
              rootPatterns = {
                ".eslintrc",
                ".eslintrc.json",
                ".eslintrc.cjs",
                ".eslintrc.js",
                ".eslintrc.yml",
                ".eslintrc.yaml",
                "package.json",
              },
              debounce = 100,
              args = {
                "--stdin",
                "--stdin-filename",
                "%filepath",
                "--format",
                "json",
              },
              parseJson = {
                errorsRoot = "[0].messages",
                line = "line",
                column = "column",
                endLine = "endLine",
                endColumn = "endColumn",
                security = "severity",
                message = "${message} [${ruleId}]",
              },
              securities = {
                [1] = "warning",
                [2] = "error",
              },
            },
          },

          -- 指定不同文件类型使用的 formatter
          formatFiletypes = {
            javascript = "perttier",
            typescript = "prettier",
            javascriptreact = "prettier",
            typescriptreact = "prettier",
            html = "prettier",
            css = "prettier",
            less = "prettier",
            scss = "prettier",
            vue = "prettier",
          },
          formatters = {
            eslint_d = {
              command = "eslint_d",
              -- 这条命令不起作用
              -- args = { "--stdin", "--fix-to-stdout", "--stdin-filename", "%filepath" },
              args = { "--fix", "%filepath" },
              isStdout = true,
            },
            prettier = {
              -- installed globally, or "./node_modules/.bin/prettier" for local install
              command = 'prettierd',
              args = { '--stdin-filepath', '%filepath' },
              rootPatterns = {
                ".prettierrc",
                ".prettierrc.json",
                ".prettierrc.toml",
                ".prettierrc.json",
                ".prettierrc.yml",
                ".prettierrc.yaml",
                ".prettierrc.json5",
                ".prettierrc.js",
                ".prettierrc.cjs",
                "prettier.config.js",
                "prettier.config.cjs"
              }
            }
          },
        },
      },
    },
  },
  init = function()
    local format = function()
      require("lazyvim.plugins.lsp.format").format({ force = true })
    end

    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- change a keymap
    -- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
    -- keys[#keys + 1] = { "gh", vim.lsp.buf.hover, desc = "Hover" }
    keys[#keys + 1] = { "gj", "]d", desc = "Next Diagnostic", remap = true }
    keys[#keys + 1] = { "gk", "[d", desc = "Prev Diagnostic", remap = true }
    keys[#keys + 1] = { "gl", vim.diagnostic.open_float, desc = "Line Diagnostics" }
    keys[#keys + 1] = { "gne", "]e", desc = "Next Error", remap = true }
    keys[#keys + 1] = { "gNe", "[e", desc = "Prev Error", remap = true }
    keys[#keys + 1] = { "gnw", "]w", desc = "Next Warning", remap = true }
    keys[#keys + 1] = { "gNw", "[w", desc = "Prev Warning", remap = true }
    keys[#keys + 1] = { "<leader>fm", format, desc = "Format Document", has = "formatting" }
    keys[#keys + 1] = { "<leader>fm", format, desc = "Format Range", mode = "v", has = "rangeFormatting" }
    keys[#keys + 1] = { "<leader>rn", "<leader>cr", desc = "Rename", remap = true }
  end,
}
