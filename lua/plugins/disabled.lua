local plugins = {
  "nvimtools/none-ls.nvim",
  "goolord/alpha-nvim",
  "RRethy/vim-illuminate",
  -- "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "hrsh7th/nvim-cmp",
  "neovim/nvim-lspconfig",
  -- 禁用这个插件，使用 coc-pair
  "echasnovski/mini.pairs",
  -- use coc-snippets instead
  "L3MON4D3/LuaSnip",
  "linrongbin16/lsp-progress.nvim",
  -- use vim native operations instead
  -- see: https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
  "mg979/vim-visual-multi",
  -- use nvim-tree instead
  "nvim-neo-tree/neo-tree.nvim",
  -- use picker in nvim-tree instead
  "s1n7ax/nvim-window-picker",
  "kevinhwang91/nvim-ufo",
  "rest-nvim/rest.nvim"
}

local disabled_plugins = {}

for _, value in pairs(plugins) do
  table.insert(disabled_plugins, {
    value,
    enabled = false,
  })
end

return disabled_plugins
