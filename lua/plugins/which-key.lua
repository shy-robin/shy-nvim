return {
  "folke/which-key.nvim",
  opts = {
    window = {
      border = "rounded",
    },
    defaults = {
      ["<leader>D"] = { name = "+diffview" },
      ["<leader>C"] = { name = "+coc" },
      ["<leader>ca"] = { name = "+code-action" },
      ["<leader>cb"] = { name = "+comment-box" },
      ["<leader>cs"] = { name = "+snippets" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")

    local presets = require("which-key.plugins.presets")
    -- 设置 operator
    presets.operators["m"] = "Marks"
    presets.operators["t"] = "Tabs"

    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
