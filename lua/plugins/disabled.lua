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
  -- coc 不支持 LuaSnip (https://github.com/neoclide/coc.nvim/discussions/4477)
  "L3MON4D3/LuaSnip",
  "linrongbin16/lsp-progress.nvim",
  -- use vim native operations instead
  -- see: https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
  "mg979/vim-visual-multi",
  -- use nvim-tree instead
  "nvim-neo-tree/neo-tree.nvim",
  -- use picker in nvim-tree instead
  "s1n7ax/nvim-window-picker",
  -- "kevinhwang91/nvim-ufo",
  -- 初始化会报错缺少依赖，先禁用这个插件
  "rest-nvim/rest.nvim",
  "folke/trouble.nvim",
  "LunarVim/bigfile.nvim",
  -- 使用 coc-markdown-preview-enhanced 代替
  -- "iamcco/markdown-preview.nvim",
  "stevearc/conform.nvim",
  "mfussenegger/nvim-lint",
  -- 使用 LazyVim 提供的 Snacks.dashboard
  "nvimdev/dashboard-nvim",
  -- 使用 LazyVim 提供的 Snacks.bigfile
  "LunarVim/bigfile.nvim",
  -- 使用 LazyVim 提供的 Snacks.statuscolumn
  "luukvbaal/statuscol.nvim",
  -- 使用 LazyVim 提供的 Snacks.indent-blankline
  "lukas-reineke/indent-blankline.nvim",
  -- 与 coc 冲突，暂时禁用
  "saghen/blink.cmp",
  -- 使用 fzf.lua 代替
  "nvim-telescope/telescope.nvim",
  -- 使用 fzf.lua 代替
  "nvim-telescope/telescope-file-browser.nvim",
  "yetone/avante.nvim",
}

local disabled_plugins = {}

for _, value in pairs(plugins) do
  table.insert(disabled_plugins, {
    value,
    enabled = false,
  })
end

return disabled_plugins
