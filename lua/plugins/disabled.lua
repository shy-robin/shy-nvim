local plugins = {
  "neoclide/coc.nvim",
  "nvim-neo-tree/neo-tree.nvim",
  "voldikss/vim-floaterm",
}

local disabled_plugins = {}

for _, value in pairs(plugins) do
  table.insert(disabled_plugins, {
    value,
    enabled = false,
  })
end

return disabled_plugins
