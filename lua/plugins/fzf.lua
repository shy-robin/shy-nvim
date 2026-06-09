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
    local toggle_hints = {
      hbind("c-w", "hidden"),
      hbind("c-e", ".gitignore"),
      hbind("c-r", "follow"),
    }
    -- files picker（<leader><leader>）不是 live 模式，没有 fuzzy 切换
    local files_header = table.concat(toggle_hints, "  ")
    -- grep（<leader>/）额外有 <c-g> 切模糊搜索
    local grep_header = table.concat(vim.list_extend(vim.deepcopy(toggle_hints), {
      hbind("c-g", "fuzzy"),
    }), "  ")
    return {
      winopts = {
        backdrop = 100,
      },
      -- live_grep 内部也走 grep 配置，所以这里一处即覆盖 <leader>/
      grep = { header = grep_header },
      files = { header = files_header },
      keymap = {
        builtin = {
          true,
          ["<Esc>"] = "hide", -- hide fzf-lua, `:FzfLua resume` to continue
          ["<C-f>"] = "toggle-help",
          -- 不能使用 <C-m> 因为它是 enter 的等效快捷键
          ["<C-o>"] = "toggle-fullscreen",
          ["<C-a>"] = "toggle-preview",
          ["<C-n>"] = "preview-page-down",
          ["<C-p>"] = "preview-page-up",
        },
        fzf = {
          true,
          ["ctrl-h"] = "prev-history",
          ["ctrl-l"] = "next-history",
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
          -- 将所选文件添加到 quickfix 列表，使用 :copen 打开列表（使用 ctrl+i 多选文件）
          ["ctrl-t"] = actions.file_sel_to_qf,
          -- 将所选文件添加到 location 列表，使用 :lopen 打开列表（使用 ctrl+i 多选文件）
          ["ctrl-y"] = actions.file_sel_to_ll,
          -- NOTE: reuse=true 必须保留，否则会被规范化为 exec_silent 动作：
          -- 切换后不会重新加载结果（toggle 看似无效），且失去 header 提示
          ["ctrl-w"] = { fn = actions.toggle_hidden, reuse = true },
          ["ctrl-e"] = { fn = actions.toggle_ignore, reuse = true },
          ["ctrl-r"] = { fn = actions.toggle_follow, reuse = true },
        },
      },
    }
  end,
}
