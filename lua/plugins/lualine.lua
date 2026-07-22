-- 部分样式参考：<https://github.dev/Parsifa1/nvim/tree/master/lua>
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    local function diff_source()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end

    local icons = require("lazyvim.config").icons

    return {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = {
          statusline = { "dashboard", "alpha", "snacks_dashboard" },
          winbar = { "dashboard", "alpha", "snacks_dashboard" },
        },
        component_separators = "",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            separator = { left = "", right = "" },
            padding = { left = 0, right = 0 },
          },
        },
        lualine_b = {
          "branch",
        },
        lualine_c = {
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 },
          },
          {
            "filename",
            symbols = { modified = "󰳻", readonly = "󰍁", unnamed = "󰡯" },
          },
          -- 显示 supermaven 的状态
          {
            function()
              -- 用 package.loaded 守卫：未加载时不 require，避免启动期把
              -- 本应 InsertEnter 懒加载的 supermaven 提前拽到启动加载。
              local api = package.loaded["supermaven-nvim.api"]
              if api and api.is_running() then
                return " "
              end
              return " "
            end,
            color = function()
              local api = package.loaded["supermaven-nvim.api"]
              if api and api.is_running() then
                return { fg = Snacks.util.color("Special") }
              end
              return { fg = Snacks.util.color("Comment") }
            end,
          },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          -- 显示 macro 记录
          {
            ---@diagnostic disable-next-line: undefined-field
            function() return require("noice").api.status.mode.get() end,
            ---@diagnostic disable-next-line: undefined-field
            cond = function() return require("noice").api.status.mode.has() end,
            color = function()
              return { fg = Snacks.util.color("WarningMsg") }
            end,
            icon = { " ", align = "left" },
          },
        },
        lualine_x = {
          {
            function()
              local ok, decorations = pcall(vim.api.nvim_get_var, "flutter_tools_decorations")
              return ok and decorations.app_version or ""
            end,
            icon = "",
          },
          {
            function()
              local ok, decorations = pcall(vim.api.nvim_get_var, "flutter_tools_decorations")
              if not ok or not decorations.device then return "" end
              local device = decorations.device
              return type(device) == "table" and device.name or tostring(device)
            end,
            icon = "",
          },
          {
            function()
              local ok, decorations = pcall(vim.api.nvim_get_var, "flutter_tools_decorations")
              if not ok or not decorations.project_config then return "" end
              local conf = decorations.project_config
              return type(conf) == "table" and (conf.name or vim.inspect(conf)) or tostring(conf)
            end,
            icon = "",
          },
          -- stylua: ignore
          -- 显示按下的键位
          -- {
          --   function() return require("noice").api.status.command.get() end,
          --   cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          --   color = Util.fg("Statement"),
          -- },
          -- stylua: ignore
          -- {
          --   function() return require("noice").api.status.mode.get() end,
          --   cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          --   color = Util.fg("Constant"),
          -- },
          -- stylua: ignore

          {
            function()
              return "  " .. require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
            color = { fg = Snacks.util.color("Debug") },
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = { fg = Snacks.util.color("Special") },
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = diff_source,
          },
          "encoding",
          "fileformat",
        },
        lualine_y = {
          "filesize",
          "selectioncount",
        },
        lualine_z = {
          "progress",
          {
            "location",
            separator = { right = "" },
          },
        },
      },
      extensions = { "lazy" },
    }
  end,
  config = function(_, opts)
    -- 让 lualine c 段背景与 Normal 一致，实现沉浸式效果
    local auto = require("lualine.themes.auto")
    local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    if normal_bg then
      local bg_hex = string.format("#%06x", normal_bg)
      local lualine_modes = { "insert", "normal", "visual", "command", "replace", "inactive", "terminal" }
      for _, field in ipairs(lualine_modes) do
        if auto[field] and auto[field].c then
          auto[field].c.bg = bg_hex
        end
      end
    end
    opts.options.theme = auto
    require("lualine").setup(opts)
  end,
}
