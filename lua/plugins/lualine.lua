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
              local api = require("supermaven-nvim.api")
              if api.is_running() then
                return " "
              end
              return " "
            end,
            color = function()
              local api = require("supermaven-nvim.api")
              if api.is_running() then
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
          -- stylua: ignore
          -- useless because using coc
          -- {
          --   function() return require("nvim-navic").get_location() end,
          --   cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
          -- },
          -- see: https://github.com/nvim-lualine/lualine.nvim/issues/906
          {
            "%{get(g:, 'coc_status', '')}",
            color = function()
              return { fg = Snacks.util.color("DiagnosticInfo") }
            end,
          },
          -- 显示 macro 记录
          {
            require("noice").api.statusline.mode.get,
            cond = require("noice").api.statusline.mode.has,
            color = function()
              return { fg = Snacks.util.color("WarningMsg") }
            end,
            icon = { " ", align = "left" },
          },
        },
        lualine_x = {
          -- Setup lsp-progress component (use coc#status instead)
          -- {
          --   function()
          --     return require("lsp-progress").progress({
          --       max_size = 80,
          --       format = function(messages)
          --         local active_clients = vim.lsp.get_active_clients()
          --         if #messages > 0 then
          --           return table.concat(messages, " ")
          --         end
          --         local client_names = {}
          --         for _, client in ipairs(active_clients) do
          --           if client and client.name ~= "" then
          --             table.insert(client_names, 1, client.name)
          --           end
          --         end
          --         return table.concat(client_names, "/")
          --       end,
          --     })
          --   end,
          --   icon = { "", align = "right" },
          -- },
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
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = { fg = Snacks.util.color("Debug") }
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
    -- 将 lualine 的背景颜色设置为透明
    local auto = require("lualine.themes.auto")
    local lualine_modes = { "insert", "normal", "visual", "command", "replace", "inactive", "terminal" }
    for _, field in ipairs(lualine_modes) do
      if auto[field] and auto[field].c then
        auto[field].c.bg = "NONE"
      end
    end
    opts.options.theme = auto
    require("lualine").setup(opts)
  end,
}
