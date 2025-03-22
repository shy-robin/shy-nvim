-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local set = vim.keymap.set
local del = vim.keymap.del

-- windows
-- 删除默认配置，不然快速按下 <leader>wr 不会触发（新版本已修复）
-- del("n", "<leader>w")
set("n", "<leader>wb", "<C-W>s", { desc = "Split window below", remap = true })
set("n", "<leader>wr", "<C-W>v", { desc = "Split window right", remap = true })
set("n", "<leader>wo", "<C-W>o", { desc = "Only keep current window", remap = true })
set("n", "<leader>we", "<C-W>=", { desc = "Equal window size", remap = true })
set("n", "<leader>wk", "5<C-W>+", { desc = "Increase window height", remap = true })
set("n", "<leader>wj", "5<C-W>-", { desc = "Decrease window height", remap = true })
set("n", "<leader>wh", "5<C-W><", { desc = "Decrease window width", remap = true })
set("n", "<leader>wl", "5<C-W>>", { desc = "Increase window width", remap = true })
-- 移除，LazyVim 已支持
-- set("n", "<leader>wm", "<C-W>_<C-W>|", { desc = "Maximize window", remap = true })

-- move lines
set("v", "J", ":move '>+1<cr>gv=gv", { desc = "Move down", silent = true })
set("v", "K", ":move '<-2<cr>gv=gv", { desc = "Move up", silent = true })

-- clear highlight search
del({ "i", "n" }, "<esc>")
-- 使用默认的 <leader>ur
-- set("n", "<leader>nh", "<cmd>nohl<cr>", { desc = "Clear hlsearch" })

-- file
del("n", "<leader>fn")
-- 注意，避免写 : 加命令的形式执行命令，不然底部栏会切换到 command 模式而导致闪烁
set("n", "<leader>fs", "<cmd>w!<cr>", { desc = "Save and format", silent = true })
set("n", "<leader>fq", "<cmd>wq<cr>", { desc = "Save and format and Quit", silent = true })
set("n", "<leader>fn", "<cmd>noa w!<cr>", { desc = "Save but Not format", silent = true })
set("n", "<leader>fN", "<cmd>enew<cr>", { desc = "New File", silent = true })

-- edit
-- bug with WhichKey: https://github.com/folke/which-key.nvim/issues/271
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

-- spell check (use coc-spell-checker instead)
-- set("n", "gns", "]s", { desc = "Next misspelled word", remap = true, silent = true })
-- set("n", "gNs", "[s", { desc = "Prev misspelled word", remap = true, silent = true })

-- reload
set("n", "<leader>rh", "<cmd>syntax sync fromstart<cr>", { desc = "Reload Syntax Highlight", silent = true })

-- diff file
-- 标记一个 buffer，当标记到两个及以上 buffer 后，开启 diff
set("n", "<leader>Dt", "<cmd>diffthis<cr>", { desc = "Diff This", silent = true })
-- 当有 split 时，直接开启 diff
set("n", "<leader>Ds", "<cmd>windo diffthis<cr>", { desc = "Diff Split", silent = true })
-- 退出 diff
set("n", "<leader>Do", "<cmd>diffoff<cr>", { desc = "Diff Off", silent = true })

-- 用法参考 LazyVim（https://github.dev/LazyVim/LazyVim）搜索 snacks.toggle
Snacks.toggle({
  name = "Transparent Background",
  get = function()
    return vim.g.transparent_enabled == true
  end,
  set = function(enabled)
    if enabled then
      vim.api.nvim_command("TransparentEnable")
    else
      vim.api.nvim_command("TransparentDisable")
    end
  end,
}):map("<leader>ub")

-- Tab page
-- reference: https://neovim.io/doc/user/tabpage.html
set("n", "<leader>th", "<cmd>tabprevious<cr>", { desc = "Tab Previous", silent = true })
set("n", "<leader>tl", "<cmd>tabnext<cr>", { desc = "Tab Next", silent = true })
set("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Tab Close", silent = true })
set("n", "<leader>tO", "<cmd>tabonly<cr>", { desc = "Tab Close Other", silent = true })
set("n", "<leader>tH", "<cmd>tabfirst<cr>", { desc = "Tab First", silent = true })
set("n", "<leader>tL", "<cmd>tablast<cr>", { desc = "Tab Last", silent = true })
-- 新建一个 tab 时，不创建一个新的 buffer 而是使用当前 buffer
-- https://vi.stackexchange.com/questions/6746/how-can-i-open-a-buffer-in-a-new-tab-leaving-the-current-window-and-buffer-intac
set("n", "<leader>tn", "<cmd>tabe %<cr>", { desc = "Tab New", silent = true })

set("n", "<leader>qq", function()
  -- 退出之前，关闭所有 floaterm
  vim.api.nvim_command("FloatermKill!")
  vim.api.nvim_command("qa")
end, { desc = "Quit All" })

--lazygit
set("n", "<leader>gb", function()
  -- 设置浮动窗口样式
  Snacks.git.blame_line({ win = { backdrop = 100, width = 0.9, height = 0.9 } })
end, { desc = "Git Blame Line" })

-- 使用 coc 的能力进行重写
Snacks.toggle({
  name = "Coc Diagnostic",
  get = function()
    return vim.fn["coc#util#get_config"]("diagnostic").enable
  end,
  set = function(enabled)
    if enabled then
      vim.fn["coc#config"]("diagnostic.enable", true)
    else
      vim.fn["coc#config"]("diagnostic.enable", false)
    end
  end,
}):map("<leader>ud")

-- 使用 coc 的能力进行重写
Snacks.toggle({
  name = "Coc Auto Format (Global)",
  get = function()
    return vim.fn["coc#util#get_config"]("coc.preferences").formatOnSave
  end,
  set = function(enabled)
    if enabled then
      vim.fn["coc#config"]("coc.preferences.formatOnSave", true)
    else
      vim.fn["coc#config"]("coc.preferences.formatOnSave", false)
    end
  end,
}):map("<leader>uf")

-- 使用 coc 的能力进行重写
Snacks.toggle({
  name = "Inlay Hints",
  get = function()
    return vim.fn["coc#util#get_config"]("inlayHint").enable and vim.fn["coc#util#get_config"]("inlayHint").display
  end,
  set = function(enabled)
    if enabled then
      vim.fn["coc#config"]("inlayHint.enable", true)
      vim.fn["coc#config"]("inlayHint.display", true)
    else
      vim.fn["coc#config"]("inlayHint.enable", false)
      vim.fn["coc#config"]("inlayHint.display", false)
    end
  end,
}):map("<leader>uh")

-- 使用 coc 的能力进行重写
Snacks.toggle({
  name = "Coc Spell Checker",
  get = function()
    return vim.fn["coc#util#get_config"]("cSpell").enabled
  end,
  set = function(enabled)
    if enabled then
      vim.fn["coc#config"]("cSpell.enabled", true)
    else
      vim.fn["coc#config"]("cSpell.enabled", false)
    end
  end,
}):map("<leader>uS")

-- lazy
del("n", "<leader>l")
del("n", "<leader>L")
set("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy" })
-- 将插件版本重置到 lock 版本
set("n", "<leader>lr", "<cmd>Lazy restore<cr>", { desc = "Lazy Restore" })
set("n", "<leader>lc", function()
  LazyVim.news.changelog()
end, { desc = "LazyVim Changelog" })

-- Supermaven 开关
Snacks.toggle({
  name = "Supermaven",
  get = function()
    local api = require("supermaven-nvim.api")
    return api.is_running()
  end,
  set = function(enabled)
    local api = require("supermaven-nvim.api")
    if enabled then
      api.start()
    else
      api.stop()
    end
  end,
}):map("<leader>ast")

-- 使用 <leader>N 代替，避免 org-roam 键位冲突
del("n", "<leader>n")


-- 显示最大字数竖线
Snacks.toggle({
  name = "Char Boundary",
  get = function()
    return vim.opt.colorcolumn._value ~= ""
  end,
  set = function(enabled)
    if enabled then
      vim.opt.colorcolumn = "80"
    else
      vim.opt.colorcolumn = ""
    end
  end,
}):map("<leader>uB")
