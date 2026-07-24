-- NOTE: 一些技巧
-- grep 时搜索内容后再按下 ctrl + g 可以进入模糊过滤
-- 可以过滤指定目录下的文件，或者使用 ! 排除某些文件

return {
  "ibhagwan/fzf-lua",
  -- 用函数形式包裹 opts，把 require 推迟到 fzf-lua 真正加载时执行，避免在启动时被急加载
  opts = function()
    local actions = require("fzf-lua").actions
    local utils = require("fzf-lua.utils")
    -- 自定义紧凑 header：fzf-lua 自动生成的格式是写死的 `<ctrl-x> to xxx`，
    -- 占地太大；设置 opts.header 字符串可整体覆盖（core.lua set_header 提前返回）。
    -- 用 <c-x> 简写并去掉 "to"，单行显示所有 toggle 提示。
    local function hbind(key, desc)
      return utils.ansi_from_hl("FzfLuaHeaderBind", "<" .. key .. ">")
        .. " "
        .. utils.ansi_from_hl("FzfLuaHeaderText", desc)
    end
    local base_hints = {
      hbind("c-h", "hidden"),
      hbind("c-y", ".gitignore"),
      hbind("c-f", "follow"),
      hbind("c-q", "quickfix"),
      hbind("c-l", "loclist"),
    }
    -- files picker 不是 live 模式，没有 grep/live_grep 切换
    local files_header = table.concat(base_hints, "  ")
    -- grep picker 额外用 <c-g> 在 grep 与 live_grep 之间切换
    local grep_header = table.concat(
      vim.list_extend(vim.deepcopy(base_hints), {
        hbind("c-g", "grep/live"),
      }),
      "  "
    )
    return {
      winopts = {
        backdrop = 100,
        -- 与 Snacks lazygit、vim-floaterm 统一浮窗尺寸（屏幕占比 0.9×0.9）
        width = 0.9,
        height = 0.9,
      },
      -- live_grep 内部也走 grep 配置，所以这里一处即可覆盖两种 grep picker
      grep = { header = grep_header },
      files = { header = files_header },
      keymap = {
        builtin = {
          true,
          ["<Esc>"] = "hide", -- hide fzf-lua, `:FzfLua resume` to continue
          -- LazyVim 在 builtin 层把 <c-f>=preview-page-down（neovim 终端映射，
          -- 会在按键到达 fzf 前拦截），置 false 解绑、让位给 fzf 侧的 toggle_follow。
          -- 注意必须用 LazyVim 的同款小写 key <c-f>（与 <C-f> 是不同的表 key）。
          ["<c-f>"] = false,
          -- 不能使用 <C-m> 因为它是 enter 的等效快捷键
          ["<C-o>"] = "toggle-fullscreen",
          ["<C-a>"] = "toggle-preview",
          ["<C-n>"] = "preview-page-down",
          ["<C-p>"] = "preview-page-up",
        },
        -- NOTE: <c-h>/<c-l> 原为 prev/next-history，现让位给 hidden 切换与 location list
        fzf = {
          true,
          -- 默认 ctrl-f = half-page-down（翻预览/列表），会顶掉 toggle_follow，置 false 解绑
          ["ctrl-f"] = false,
        },
      },
      fzf_opts = {
        ["--cycle"] = true,
        ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
      },
      actions = {
        -- Below are the default actions, setting any value in these tables will override
        -- the defaults, to inherit from the defaults change [1] from `false` to `true`
        files = {
          true, -- uncomment to inherit all the below in your custom config
          -- 将所选文件添加到 quickfix 列表，使用 :copen 打开列表（Tab 多选文件）
          ["ctrl-q"] = actions.file_sel_to_qf,
          -- 将所选文件添加到 location 列表，使用 :lopen 打开列表（Tab 多选文件）
          ["ctrl-l"] = actions.file_sel_to_ll,
          -- NOTE: reuse=true 必须保留，否则会被规范化为 exec_silent 动作：
          -- 切换后不会重新加载结果（toggle 看似无效），且失去 header 提示
          -- 注意 ignore 不能用 <c-i>：终端里 ^I 即 Tab，会顶掉多选
          ["ctrl-h"] = { fn = actions.toggle_hidden, reuse = true },
          ["ctrl-y"] = { fn = actions.toggle_ignore, reuse = true },
          ["ctrl-f"] = { fn = actions.toggle_follow, reuse = true },
        },
      },
    }
  end,
}
