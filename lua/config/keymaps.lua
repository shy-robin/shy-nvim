-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local set = vim.keymap.set
local del = vim.keymap.del

-- windows
set("n", "<leader>wb", "<C-W>s", { desc = "Split window below", remap = true })
set("n", "<leader>wr", "<C-W>v", { desc = "Split window right", remap = true })
set("n", "<leader>wo", "<C-W>o", { desc = "Only keep current window", remap = true })
set("n", "<leader>we", "<C-W>=", { desc = "Equal window size", remap = true })
set("n", "<leader>wk", "5<C-W>+", { desc = "Increase window height", remap = true })
set("n", "<leader>wj", "5<C-W>-", { desc = "Decrease window height", remap = true })
set("n", "<leader>wh", "5<C-W><", { desc = "Decrease window width", remap = true })
set("n", "<leader>wl", "5<C-W>>", { desc = "Increase window width", remap = true })

-- remove default Move lines
del("n", "<A-j>")
del("n", "<A-k>")
del("i", "<A-j>")
del("i", "<A-k>")
del("v", "<A-j>")
del("v", "<A-k>")

-- move lines
set("v", "J", ":move '>+1<cr>gv=gv", { desc = "Move down", silent = true })
set("v", "K", ":move '<-2<cr>gv=gv", { desc = "Move up", silent = true })

-- clear highlight search
del({ "i", "n" }, "<esc>")
set("n", "<leader>nh", "<cmd>nohl<cr>", { desc = "Clear hlsearch" })

-- file
del("n", "<leader>fn")
-- 注意，避免写 : 加命令的形式执行命令，不然底部栏会切换到 command 模式而导致闪烁
set("n", "<leader>fs", "<cmd>w!<cr>", { desc = "Save and format", silent = true })
set("n", "<leader>fq", "<cmd>wq<cr>", { desc = "Save and format and Quit", silent = true })
set("n", "<leader>fn", "<cmd>noa w!<cr>", { desc = "Save but Not format", silent = true })
set("n", "<leader>fN", "<cmd>enew<cr>", { desc = "New File", silent = true })

-- edit
set({ "n", "v" }, "d", '"_d', { desc = "Delete with no register" })
set({ "n", "v" }, "dd", '"_dd', { desc = "Delete a line with no register" })
set({ "n", "v" }, "D", '"_D', { desc = "Delete backward with no register" })
set({ "n", "v" }, "c", '"_c', { desc = "Change with no register" })
set({ "n", "v" }, "cc", '"_cc', { desc = "Change a line with no register" })
set({ "n", "v" }, "C", '"_C', { desc = "Change backward with no register" })
set({ "n", "v" }, "s", '"_s', { desc = "Replace with no register" })
set({ "n", "v" }, "S", '"_S', { desc = "Replace a line with no register" })
set("n", "X", "yydd", { desc = "Cut a line" })
set("v", "p", '"_dp', { desc = "Paste with no register" })

-- cmdline
set("c", "<C-j>", "<C-n>", { desc = "Select Next Item", remap = true })
set("c", "<C-k>", "<C-p>", { desc = "Select Prev Item", remap = true })

-- spell check
set("n", "gns", "]s", { desc = "Next misspelled word", remap = true, silent = true })
set("n", "gNs", "[s", { desc = "Prev misspelled word", remap = true, silent = true })

-- reload
set("n", "<leader>rh", "<cmd>syntax sync fromstart<cr>", { desc = "Reload Syntax Highlight", silent = true })
