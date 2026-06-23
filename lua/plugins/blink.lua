local kind_text_map = {
  Text = "󰉿",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰜢",
  Variable = "",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌆",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "󰈇",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "󰙅",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "",
}

return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "onsails/lspkind.nvim",
    },
    opts = {
      -- 1. 快捷键设置
      -- -- 'super-tab' for mappings similar to vscode (tab to accept)
      keymap = {
        preset = "super-tab",
        ["<C-y>"] = false,
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "select_and_accept" },
      },

      -- 2. 补全源配置
      sources = {
        -- 如果你想添加额外的源（比如外部插件提供的）
        -- providers = { ... }
      },

      -- 命令行（: / ?）补全源：blink 此处支持传函数动态决定（见 sources/lib/init.lua）。
      -- 修两个问题：
      -- 1) bigfile（超大 buffer）下直接返回空，避免 buffer 源每次按键扫描上千万行 →
      --    这是“快速输入命令仍卡顿”的真凶（blink 命令行的 enabled 早于 vim.b.completion
      --    判断，故仅设 vim.b.completion=false 挡不住命令行补全）。
      -- 2) blink 原始默认对所有模式都含 buffer 源，连 `:` 也会扫描整个 buffer；这里让
      --    `:`/`@` 只用命令源，`/`、`?` 才用 buffer 源做搜索词补全（普通文件也更跟手）。
      cmdline = {
        sources = function()
          if vim.b.bigfile then
            return {}
          end
          local t = vim.fn.getcmdtype()
          if t == "/" or t == "?" then
            return { "buffer" }
          end
          if t == ":" or t == "@" then
            return { "cmdline" }
          end
          return {}
        end,
      },

      -- 3. 界面美化
      completion = {
        menu = {
          border = "rounded", -- 圆角边框
          draw = {
            -- 定义显示的列：第一列显示图标和类型，第二列显示补全的主体，第三列显示来源
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", gap = 1 },
              { "source_name" },
            },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  -- 如果映射表里有就用映射的，没有就返回原名
                  return kind_text_map[ctx.kind] or ctx.kind
                end,
                highlight = function(ctx)
                  -- 在用到时才 require，避免在启动时急加载 mini.icons
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
        documentation = { window = { border = "rounded" } },
        ghost_text = { enabled = false },
      },

      -- 4. 签名帮助 (类似代码参数提示)
      signature = { enabled = true, window = { border = "rounded" } },
    },
  },
}
