return {
  "nvimdev/guard.nvim",
  -- Builtin configuration, optional
  dependencies = {
    "nvimdev/guard-collection",
  },
  config = function()
    local ft = require("guard.filetype")

    -- Assuming you have guard-collection
    -- 格式化工具可以从 mason 里安装，使用 <lader>cm 查看
    ft("lua"):fmt("stylua")
    ft("javascript,typescript,javascriptreact,typescriptreact,html,css,less,scss,vue,markdown,yaml"):fmt("prettier")

    -- Call setup() LAST!
    require("guard").setup({
      -- the only options for the setup function
      fmt_on_save = true,
      -- Use lsp if no formatter was defined for this filetype
      lsp_as_default_formatter = true,
    })
  end,
}
