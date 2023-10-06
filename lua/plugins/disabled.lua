local plugins = {
  "nvimtools/none-ls.nvim",
  "goolord/alpha-nvim",
  "RRethy/vim-illuminate",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "hrsh7th/nvim-cmp",
  "neovim/nvim-lspconfig",
}

local disabled_plugins = {}

for _, value in pairs(plugins) do
  table.insert(disabled_plugins, {
    value,
    enabled = false,
  })
end

return disabled_plugins
