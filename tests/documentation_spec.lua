-- Run through scripts/check.sh. User-facing documentation must stay aligned with
-- the configured providers, commands, mapping behavior, and maintenance policy.

local repo = vim.env.NVIM_CHECK_REPO or vim.fn.getcwd()
local function read(relative_path)
  local lines = assert(vim.fn.readfile(repo .. "/" .. relative_path), "cannot read " .. relative_path)
  return table.concat(lines, "\n")
end

local function check(content, expected, message)
  assert(content:find(expected, 1, true) ~= nil, message .. ": missing " .. expected)
end

local function reject(content, unexpected, message)
  assert(content:find(unexpected, 1, true) == nil, message .. ": stale " .. unexpected)
end

local function mapping_block(content, key, occurrence)
  local needle = '      "' .. key .. '",'
  local start = 1
  for _ = 1, occurrence or 1 do
    start = assert(content:find(needle, start, true), "cannot find mapping block for " .. key)
    start = start + #needle
  end
  local finish = assert(content:find("\n    },", start, true), "cannot finish mapping block for " .. key)
  return content:sub(start - #needle, finish)
end

local readme = read("README.md")
local lazy_config = read("lua/config/lazy.lua")
local fzf = read("lua/plugins/fzf.lua")
local supermaven = read("lua/plugins/supermaven.lua")
local lazygit = read("lua/plugins/lazygit.lua")
local floaterm = read("lua/plugins/vim-floaterm.lua")
local markdown_preview = read("lua/plugins/markdown-preview.lua")
local markdown_preview_util = read("lua/util/markdown_preview.lua")
local keymaps = read("lua/config/keymaps.lua")
local flash = read("lua/plugins/flash.lua")
local nvim_tree = read("lua/plugins/nvim-tree.lua")
local scissors = read("lua/plugins/scissors.lua")
local external_commands = read("lua/util/external_commands.lua")

check(fzf, '"ibhagwan/fzf-lua"', "configured search provider")
check(fzf, 'hbind("c-g", "grep/live")', "configured fzf-lua Ctrl-G header")
reject(lazy_config, "lazyvim.plugins.extras.editor.fzf", "unconfigured LazyVim fzf extra")
reject(fzf, '"<leader><space>"', "unconfigured fzf-lua file mapping")
reject(fzf, '"<leader>/"', "unconfigured fzf-lua grep mapping")
check(readme, "https://github.com/ibhagwan/fzf-lua", "documented search provider")
reject(readme, "https://github.com/nvim-telescope/telescope.nvim", "documented search provider")
check(readme, "`:FzfLua files`", "documented fzf-lua files command")
check(readme, "`:FzfLua live_grep`", "documented fzf-lua grep command")
reject(readme, "<kbd>leader</kbd> + <kbd>Space</kbd>", "unconfigured fzf-lua file mapping")
check(readme, "grep / live_grep", "documented fzf-lua Ctrl-G behavior")
reject(readme, "切换 grep 模糊模式", "documented fzf-lua Ctrl-G behavior")
local fzf_controls = {
  { source = '["<Esc>"] = "hide"', docs = "| 隐藏 fzf-lua | <kbd>Esc</kbd>" },
  { source = '["<C-o>"] = "toggle-fullscreen"', docs = "切换全屏 / 预览" },
  { source = '["<C-a>"] = "toggle-preview"', docs = "<kbd>Ctrl</kbd> + <kbd>o</kbd> / <kbd>Ctrl</kbd> + <kbd>a</kbd>" },
  { source = '["ctrl-q"] = actions.file_sel_to_qf', docs = "发送到 quickfix / location list" },
  { source = '["ctrl-l"] = actions.file_sel_to_ll', docs = "<kbd>Ctrl</kbd> + <kbd>q</kbd> / <kbd>Ctrl</kbd> + <kbd>l</kbd>" },
  { source = '["ctrl-h"] = { fn = actions.toggle_hidden', docs = "切换 hidden 文件" },
  { source = '["ctrl-y"] = { fn = actions.toggle_ignore', docs = "切换 `.gitignore` 过滤" },
  { source = '["ctrl-f"] = { fn = actions.toggle_follow', docs = "切换符号链接跟随" },
}
for _, control in ipairs(fzf_controls) do
  check(fzf, control.source, "configured fzf-lua control")
  check(readme, control.docs, "documented fzf-lua control")
end
check(readme, "neovim](https://neovim.io/) >= **0.11.2**", "minimum Neovim version")

check(lazygit, '"kdheepak/lazygit.nvim"', "configured lazygit integration")
check(readme, "https://github.com/kdheepak/lazygit.nvim", "documented lazygit integration")

check(supermaven, '"supermaven-inc/supermaven-nvim"', "configured AI provider")
check(supermaven, 'accept_suggestion = "<C-y>"', "configured Supermaven accept mapping")
check(supermaven, 'clear_suggestion = "<C-]>"', "configured Supermaven clear mapping")
check(supermaven, 'accept_word = "<C-w>"', "configured Supermaven word mapping")
check(supermaven, '{ "<leader>asl", "<cmd>SupermavenShowLog<cr>"', "configured Supermaven log mapping")
check(supermaven, '{ "<leader>asr", "<cmd>SupermavenRestart<cr>"', "configured Supermaven restart mapping")
check(keymaps, 'map("<leader>ast")', "configured Supermaven toggle mapping")
check(keymaps, "api.start()", "configured Supermaven start behavior")
check(keymaps, "api.stop()", "configured Supermaven stop behavior")
check(readme, "https://github.com/supermaven-inc/supermaven-nvim", "documented AI provider")
for _, mapping in ipairs({ "<C-y>", "<C-]>", "<C-w>", "<leader>asl", "<leader>asr", "<leader>ast" }) do
  check(readme, "`" .. mapping .. "`", "documented Supermaven mapping")
end
check(readme, "`:SupermavenShowLog`", "documented Supermaven log behavior")
check(readme, "`:SupermavenRestart`", "documented Supermaven restart behavior")
for _, removed in ipairs({ "avante.nvim", "llm.nvim", "opencode.nvim" }) do
  reject(readme:lower(), removed, "AI provider list")
end

check(floaterm, '"voldikss/vim-floaterm"', "configured terminal provider")
check(readme, "https://github.com/voldikss/vim-floaterm", "documented terminal provider")
local floaterm_mappings = {
  { key = "<C-o>", occurrence = 1, command = "<cmd>FloatermToggle<cr>", docs = "<kbd>Ctrl</kbd> + <kbd>o</kbd>" },
  { key = "<C-o>", occurrence = 2, command = "<cmd>FloatermToggle<cr>", terminal = true },
  { key = "<C-n>", command = "<cmd>FloatermNew<cr>", terminal = true, docs = "<kbd>Ctrl</kbd> + <kbd>n</kbd>" },
  { key = "<C-h>", command = "<cmd>FloatermPrev<cr>", terminal = true, docs = "<kbd>h</kbd>" },
  { key = "<C-l>", command = "<cmd>FloatermNext<cr>", terminal = true, docs = "<kbd>l</kbd>" },
  { key = "<C-q>", command = "<cmd>FloatermKill<cr>", terminal = true, docs = "<kbd>Ctrl</kbd> + <kbd>q</kbd>" },
  { key = "<leader>tb", command = "FloatermNew --wintype=split", docs = "`<leader>tb`" },
  { key = "<leader>tr", command = "FloatermNew --wintype=vsplit", docs = "`<leader>tr`" },
}
for _, mapping in ipairs(floaterm_mappings) do
  local block = mapping_block(floaterm, mapping.key, mapping.occurrence)
  check(block, mapping.command, "configured Floaterm mapping behavior")
  if mapping.terminal then
    check(block, 'ft = "floaterm"', "configured Floaterm filetype constraint")
    check(block, 'mode = "t"', "configured Floaterm mode constraint")
  end
  if mapping.docs then
    check(readme, mapping.docs, "documented Floaterm mapping")
  end
end
check(readme, "`:FloatermToggle`", "documented Floaterm toggle behavior")
check(readme, "`:FloatermKill`", "documented Floaterm quit behavior")
for _, optional_terminal in ipairs({
  { command = "ranger", key = "`<leader>tor`" },
  { command = "yazi", key = "`<leader>y`" },
}) do
  check(floaterm, 'open_optional_terminal("' .. optional_terminal.command .. '")', "guarded optional Floaterm command")
  check(readme, optional_terminal.command, "documented optional Floaterm dependency")
  check(readme, optional_terminal.key, "documented optional Floaterm mapping")
end
check(keymaps, 'set("n", "<leader>qq", function()', "configured quit-all mapping")
check(keymaps, 'vim.api.nvim_command("FloatermKill!")', "configured quit-all Floaterm cleanup")
check(keymaps, 'vim.api.nvim_command("qa")', "configured quit-all Neovim behavior")
check(readme, "| 退出全部 | `<leader>qq` | 先执行 `:FloatermKill!`，再退出 Neovim |", "documented quit-all behavior")

check(markdown_preview, '"iamcco/markdown-preview.nvim"', "configured Markdown Preview provider")
check(
  markdown_preview,
  'cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" }',
  "configured Markdown Preview commands"
)
check(markdown_preview_util, "npx --yes yarn install", "configured Markdown Preview build command")
check(markdown_preview, '{ "gom", function() require("util.mkdp").toggle() end', "configured Markdown Preview toggle")
check(markdown_preview, '{ "goM", function() require("util.mkdp").pick() end', "configured Markdown Preview list")
check(readme, "https://github.com/iamcco/markdown-preview.nvim", "documented Markdown Preview provider")
check(readme, "Node.js", "Markdown Preview dependency")
check(readme, "npm", "Markdown Preview dependency")
check(readme, "npx", "Markdown Preview dependency")
check(readme, "`sh`", "Markdown Preview shell dependency")
check(readme, "安装会停止", "Markdown Preview build failure behavior")
check(readme, "ImageMagick", "documented non-macOS image dimensions fallback")
check(readme, "sips", "documented macOS image dimensions provider")
check(readme, "不需要 `jq`", "documented built-in Scissors formatter")
reject(scissors, "jsonFormatter", "obsolete Scissors formatter option")
check(external_commands, 'if sysname == "Darwin" then', "platform-specific du command")
check(external_commands, 'pcall(vim.system', "guarded process spawning")
check(readme, "`gom`", "documented Markdown Preview toggle")
check(readme, "`goM`", "documented Markdown Preview list")
for _, command in ipairs({ ":MarkdownPreviewToggle", ":MarkdownPreview", ":MarkdownPreviewStop" }) do
  check(readme, "`" .. command .. "`", "documented Markdown Preview command")
end
check(readme, "git clone --depth 1 --branch nvim-0.11", "maintenance branch clone command")

local edit_mappings = {
  { source = [[set({ "n", "v" }, "d", '"_d']], docs = "| `d`、`dd`、`D` | Normal、Visual | 删除到黑洞寄存器 |" },
  { source = [[set({ "n", "v" }, "c", '"_c']], docs = "| `c`、`cc`、`C` | Normal、Visual | 修改到黑洞寄存器 |" },
  { source = [[set({ "n", "v" }, "s", '"_s']], docs = "| `s`、`S` | Normal、Visual | 替换/修改到黑洞寄存器 |" },
  { source = [[set("n", "X", "yydd"]], docs = "| `X` | Normal | `yydd`：复制当前行后删除，相当于剪切整行 |" },
}
for _, mapping in ipairs(edit_mappings) do
  check(keymaps, mapping.source, "configured personalized edit behavior")
  check(readme, mapping.docs, "documented personalized edit behavior")
end

check(
  flash,
  '"f",\n      mode = { "n", "x", "o" },\n      function()\n        require("flash").jump()',
  "configured f Flash mapping modes and behavior"
)
check(
  flash,
  '"F",\n      mode = { "n", "o", "x" },\n      function()\n        require("flash").treesitter()',
  "configured F Flash mapping modes and behavior"
)
check(readme, "| `f` | Normal、Visual、Operator-pending | Flash jump，而非标准字符查找 |", "documented f mapping behavior")
check(
  readme,
  "| `F` | Normal、Visual、Operator-pending | Flash Treesitter jump，而非标准反向字符查找 |",
  "documented F mapping behavior"
)

local tree_mappings = {
  { key = "<C-f>", action = "grep_at_current_tree_node" },
  { key = "d", action = "api.fs.remove" },
  { key = "s", action = "api.node.run.system" },
  { key = "f", action = "api.filter.live.start" },
  { key = "F", action = "api.filter.live.clear" },
}
for _, mapping in ipairs(tree_mappings) do
  check(nvim_tree, 'set("n", "' .. mapping.key .. '", ' .. mapping.action, "configured nvim-tree mapping")
end
check(nvim_tree, 'require("fzf-lua").live_grep({', "configured nvim-tree grep behavior")
check(readme, "在 nvim-tree 内搜索文本", "documented nvim-tree grep mapping")
check(readme, "`d` 删除节点、`s` 执行系统命令、`f` 开始实时过滤、`F` 清除实时过滤", "documented nvim-tree mapping behavior")

local changelog = read("CHANGELOG.md")
local unreleased_start = assert(changelog:find("## [unreleased]", 1, true), "cannot find unreleased changelog")
local next_heading = assert(changelog:find("\n## ", unreleased_start + 1, true), "cannot finish unreleased changelog")
local unreleased = changelog:sub(unreleased_start, next_heading - 1)
check(unreleased, "最低 Neovim 版本要求升级至 0.11.2", "minimum version changelog")
check(unreleased, "### Not planned", "abandoned changelog items")
reject(unreleased, "- [x]", "completed unreleased checklist item")
reject(unreleased, "org-mode 支持", "completed orgmode item")
reject(unreleased, "生成注释（使用 neogen", "completed neogen item")

local todo = read("TODO.md")
reject(todo, "AI commit", "removed AI integration TODO")

print("OK documentation matches configured providers, commands, modes, and mapping behavior")
