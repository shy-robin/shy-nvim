local plugins = {
  "nvimtools/none-ls.nvim",
  "goolord/alpha-nvim",
  "RRethy/vim-illuminate",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "hrsh7th/nvim-cmp",
  "neovim/nvim-lspconfig",
  "nvim-treesitter/nvim-treesitter",
  -- 禁用这个插件，使用 coc-pair
  "echasnovski/mini.pairs"
}

local disabled_plugins = {}

for _, value in pairs(plugins) do
  table.insert(disabled_plugins, {
    value,
    enabled = false,
  })
end

return disabled_plugins
