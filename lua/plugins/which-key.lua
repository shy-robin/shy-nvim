return {
  "folke/which-key.nvim",
  opts = {
    window = {
      border = "rounded",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")

    local presets = require("which-key.plugins.presets")
    -- 设置 operator
    presets.operators["t"] = "Tabs"

    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
