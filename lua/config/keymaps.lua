-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local set = vim.keymap.set

-- windows
set("n", "<leader>wb", "<C-W>s", { desc = "Split window below", remap = true })
set("n", "<leader>wr", "<C-W>v", { desc = "Split window right", remap = true })
set("n", "<leader>wo", "<C-W>o", { desc = "Only keep current window", remap = true })
set("n", "<leader>we", "<C-W>=", { desc = "Equal window size", remap = true })
set("n", "<leader>wk", "5<C-W>+", { desc = "Increase window height", remap = true })
set("n", "<leader>wj", "5<C-W>-", { desc = "Decrease window height", remap = true })
set("n", "<leader>wh", "5<C-W><", { desc = "Decrease window width", remap = true })
set("n", "<leader>wl", "5<C-W>>", { desc = "Increase window width", remap = true })
