return {
  {
    "saghen/blink.cmp",
    opts = {
      -- 1. 快捷键设置 (Presets: 'default', 'super-tab', 'enter')
      keymap = { preset = "super-tab" },

      -- 2. 补全源配置
      sources = {
        -- 如果你想添加额外的源（比如外部插件提供的）
        -- providers = { ... }
      },

      -- 3. 界面美化
      completion = {
        menu = { border = "rounded" },
        documentation = { window = { border = "rounded" } },
      },

      -- 4. 签名帮助 (类似代码参数提示)
      signature = { enabled = true, window = { border = "rounded" } },
    },
  },
}
