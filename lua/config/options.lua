-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options

-- local opt = vim.opt

-- 拼写检查跳过中文（CJK）字符
vim.opt.spelllang = { "en", "cjk" }

-- 修复 snacks dashboard 启动时偶发的「闪一下 + 启动页下移一两行」：
-- noice 启动后会挂载 ext_cmdline/ext_messages，Neovim 内核随即把 cmdheight 从 1
-- 改成 0（多出一行）。这发生在 dashboard 首次居中绘制之后，触发 snacks 的
-- WinResized 重新居中 → 重绘抖动。提前把 cmdheight 设为它最终的稳定值 0，
-- 让首屏就以正确高度绘制，消除这次 resize。
vim.opt.cmdheight = 0

-- 显示最大字数竖线
-- opt.colorcolumn = ""

-- 滚动边距，影响 zt zb
-- opt.scrolloff = 0 -- Lines of context
-- opt.sidescrolloff = 0 -- Columns of context

-- so that `` is visible in markdown files
-- opt.conceallevel = 0

-- 影响 html 标签换行
-- opt.formatoptions = "tcqj"

-- 取消 lualine 对 trouble.nvim 的依赖（https://www.lazyvim.org/plugins/ui#lualinenvim）
-- vim.g.trouble_lualine = false

-- 超过设置大小，只会开启 vim 本身的语法高亮，避免卡顿
-- vim.g.bigfile_size = 1024 * 1024 * 0.4 -- 0.4 MB

-- lazygit 不使用当前主题颜色
-- vim.g.lazygit_config = false

vim.diagnostic.config({
  float = {
    border = "rounded",
  },
})

-- 含超长行的 markdown（数据导出 / 超宽表格等）会触发 tree-sitter markdown 解析器
-- 的全量解析（Snacks indent 的 scope 检测、treesitter 折叠都会对整个 buffer 做
-- 全量 parse），内存几秒内飙到数十 G。把这类文件识别成 bigfile，复用 Snacks bigfile
-- 机制一次性关掉 tree-sitter / 折叠 / render-markdown 等重型功能。Snacks 自带检测只看
-- 总大小和“平均”行长，命不中“短行很多、仅个别行超长”的文件，故按“最长行”补一层判断。
-- 注意：bigfile 下 markdown-preview 仍可用，见 mkdp_command_for_global。
local function md_bigfile(path, buf)
  if not path or not buf then
    return
  end
  if vim.fn.getfsize(path) > 400 * 1024 then
    return -- 体积大的文件交给 Snacks 按大小处理
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if #line > 1000 then
      return "bigfile"
    end
  end
end

vim.filetype.add({
  pattern = {
    [".*%.md"] = { md_bigfile, { priority = 100 } },
    [".*%.markdown"] = { md_bigfile, { priority = 100 } },
  },
})
