local Bigfile = require("util.bigfile")

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      width = 93,
      formats = {
        key = function(item)
          return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
        end,
      },
      autokeys = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", -- autokey sequence
      sections = {
        { section = "header" },
        {
          text = { { os.date("%Y-%m-%d %H:%M:%S"), hl = "@property" } },
          align = "center",
          padding = 1,
        },
        -- 自定义文本，使其放在一行
        {
          align = "center",
          padding = 1,
          text = {
            { " File [f] ", hl = "@property" },
            { " New [n] ", hl = "@property" },
            { " Text [g] ", hl = "@property" },
            { " Recent [r] ", hl = "@property" },
            { " Config [c] ", hl = "@property" },
            { " Session [s] ", hl = "@property" },
            { "󰒲 Lazy [l] ", hl = "@property" },
            { " Quit [q]", hl = "@property" },
          },
        },
        -- 隐藏快捷键
        { key = "f", action = ":lua Snacks.dashboard.pick('files')", hidden = true },
        { key = "n", action = ":ene | startinsert", hidden = true },
        { key = "g", action = ":lua Snacks.dashboard.pick('live_grep')", hidden = true },
        { key = "r", action = ":lua Snacks.dashboard.pick('oldfiles')", hidden = true },
        {
          key = "c",
          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          hidden = true,
        },
        { key = "s", section = "session", hidden = true },
        { key = "l", action = ":Lazy", enabled = package.loaded.lazy ~= nil, hidden = true },
        { key = "q", action = ":qa", hidden = true },

        { icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = 2 },
        { icon = " ", title = "Projects", section = "projects", indent = 3, padding = 2 },
        { section = "startup", padding = 1 },
        {
          align = "center",
          text = "🚀 Sharp tools make good work.",
        },
      },
    },
    bigfile = {
      enabled = true,
      -- 关闭“Big file detected”提示：它是两行消息，启动期(noice/notifier 尚未就绪)会作为
      -- 原生多行消息显示，超过命令行高度→触发 “Press any key to continue” 阻塞提示；该阻塞
      -- 又让 VimEnter 之后才跑的 kill_noice 无法执行，于是提示框卡死。关掉即从源头消除。
      notify = false,
      size = 0.4 * 1024 * 1024, -- 0.4MB
      -- 超过最大限制，不使用任何渲染，防止卡顿
      -- Enable or disable features when big file detected
      ---@param ctx {buf: number, ft:string}
      setup = function(ctx)
        -- 标识大文件类型（LazyVim/Supermaven 据此不挂载 Treesitter/LSP/补全）。
        -- 必须放在最前，避免后续可选插件减负失败时遗漏 bigfile 标志。
        vim.b.bigfile = true

        -- 窗口选项由生命周期模块按窗口保存/恢复；MatchParen 只在首个 bigfile
        -- 进入时关闭，并仅在确由此处关闭且最后一个 bigfile 删除后恢复。
        local new_buffer = Bigfile.enter(ctx.buf)
        vim.b.minianimate_disable = true
        vim.b.miniindentscope_disable = true -- 关闭 mini.indentscope（若启用）
        vim.b.snacks_indent = false -- 关闭 snacks 缩进引导/作用域（每次重绘都会跑装饰器）
        vim.b.completion = false
        vim.b.autoformat = false -- 关闭 format-on-save：对千万行跑 prettier 会卡死保存

        -- gitsigns 每次改动都会对整个 buffer 做 diff，几百 MB 的文件极慢，直接 detach
        pcall(function()
          require("gitsigns").detach(ctx.buf)
        end)

        -- noice 用居中浮窗显示命令行，进/出命令模式都要创建/销毁浮窗并整屏重绘，
        -- 超大 buffer 下这次重绘很贵（实测进出命令模式明显卡顿）。noice 没有按 buffer
        -- 关闭的开关，故打开超大文件时整体关掉 noice，待它（及所有其他超大文件）关闭后
        -- 再恢复——只在“打开/关闭超大文件”两个时机各重绘一次，不会在频繁切 buffer 时反复闪烁。
        local function noice_running()
          local ok_config, noice_config = pcall(require, "noice.config")
          if not (ok_config and type(noice_config.is_running) == "function") then
            return nil
          end
          local ok_running, running = pcall(noice_config.is_running)
          if not ok_running then
            return nil
          end
          return running
        end

        local function kill_noice()
          if Bigfile.count() == 0 or vim.g._bigfile_noice_disabled then
            return
          end
          local ok_noice, noice = pcall(require, "noice")
          local was_running = noice_running()
          if was_running == false then
            return
          end
          -- noice.disable() may set _running=false before a later step fails. If that
          -- happens, immediately roll it back; if rollback fails, retain ownership so
          -- the final bigfile cleanup can retry while cmdheight remains protected.
          if ok_noice and pcall(noice.disable) then
            vim.g._bigfile_noice_disabled = true
            -- 关键：noice 在 enable 时会把 cmdheight 置 0。启动竞态下它的 VimEnter enable
            -- 会覆盖 BufReadPre 设的 1，故在 disable 之后再强制设回 1——保证“noice 关闭”
            -- 期间 cmdheight≥1，否则原生消息会触发 hit-enter 卡死提示框。
            vim.o.cmdheight = 1
          elseif was_running == true then
            if noice_running() == false then
              if pcall(noice.enable) then
                vim.o.cmdheight = 0
              else
                vim.g._bigfile_noice_disabled = true
                vim.o.cmdheight = 1
              end
            elseif noice_running() == true then
              vim.o.cmdheight = 0
            end
          end
        end
        -- 启动顺序竞态：用 `nvim 大文件` 直接打开时，bigfile 的 FileType 在启动期就触发，
        -- 而 noice(lazy=false) 的 enable() 注册在 VimEnter（晚于 FileType）。若此刻直接
        -- disable，随后 VimEnter 又会把 noice 打开。故启动期打开时，把 disable 推迟到
        -- VimEnter 之后（schedule_wrap 确保排在 noice 的 enable 之后）再执行。
        if new_buffer then
          if vim.v.vim_did_enter == 1 then
            kill_noice()
          else
            vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = vim.schedule_wrap(kill_noice) })
          end
          vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
            buffer = ctx.buf,
            once = true,
            callback = function(args)
              if not Bigfile.leave(args.buf) then
                return
              end
              if vim.g._bigfile_noice_disabled then
                local ok = pcall(function()
                  require("noice").enable()
                end)
                if not ok then
                  vim.o.cmdheight = 1
                  return
                end
                vim.g._bigfile_noice_disabled = false
                -- noice 恢复后还原 cmdheight=0（打开大文件时 BufReadPre 把它设成了 1，
                -- 见 options.lua：cmdheight=0 仅在 noice 接管消息时才可用）。
                vim.o.cmdheight = 0
              elseif noice_running() == true then
                -- 启动期 scheduled disable 尚未来得及执行时，最后一个 bigfile 已
                -- 删除；Noice 仍在运行，才可安全撤销 BufReadPre 的 cmdheight=1。
                vim.o.cmdheight = 0
              end
            end,
          })
        end

        -- 仅对“中等偏大”（< 10MB）的文件恢复内置正则语法高亮；几百 MB 的文件一旦
        -- 开启 syntax，每次滚动/编辑都会触发巨量正则扫描，这才是编辑卡顿的主因，
        -- 故对超大文件彻底关闭语法高亮。
        local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(ctx.buf))
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(ctx.buf) then
            return
          end
          vim.bo[ctx.buf].syntax = (fsize > 0 and fsize < 10 * 1024 * 1024) and ctx.ft or "off"
        end)
      end,
    },
    scroll = {
      enabled = false,
    },
    win = {
      -- 设置所有浮动窗口边框透明
      backdrop = 100,
    },
    image = {
      enabled = true,
    },
    lazygit = {
      -- 专门针对 lazygit 浮窗的配置
      win = {
        border = "rounded", -- 给 lazygit 加上圆角边框
        -- 与 fzf-lua、vim-floaterm 统一浮窗尺寸（屏幕占比 0.9×0.9）
        width = 0.9,
        height = 0.9,
      },
    },
  },
  keys = {
    {
      "<leader>N",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
  },
  init = function()
    -- 注册快捷调试打印命令 dd，例如：`: lua dd(vim.fn.getcwd())`
    -- 参考：https://github.com/folke/snacks.nvim/blob/main/docs/debug.md
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command
      end,
    })
  end,
}
