local mini_icons = require("mini.icons")

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
                  local _, hl, _ = mini_icons.get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
        documentation = { window = { border = "rounded" } },
      },

      -- 4. 签名帮助 (类似代码参数提示)
      signature = { enabled = true, window = { border = "rounded" } },
    },
  },
}
