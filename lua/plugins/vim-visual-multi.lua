return {
  "mg979/vim-visual-multi",
  event = "VeryLazy",
  config = function()
    -- 主题：https://github.com/mg979/vim-visual-multi/wiki/Highlight-colors
    vim.g.VM_theme = "ocean"
    vim.g.VM_default_mappings = 0
    -- 快捷键：https://github.com/mg979/vim-visual-multi/blob/724bd53adfbaf32e129b001658b45d4c5c29ca1a/autoload/vm/plugs.vim
    vim.keymap.set("n", "<leader>j", "<Plug>(VM-Add-Cursor-Down)", { desc = "VM Add Cursor Down" })
    vim.keymap.set("n", "<leader>k", "<Plug>(VM-Add-Cursor-Up)", { desc = "VM Add Cursor Up" })
    vim.keymap.set("n", "<leader>A", "<Plug>(VM-Select-All)", { desc = "VM Select All" })
    -- not work!
    -- vim.keymap.set("n", "<leader>a", "<Plug>(VM-Add-Cursor-At-Pos)", { desc = "VM Add Cursor" })
  end,
}
