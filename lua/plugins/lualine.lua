return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    local icons = require("lazyvim.config").icons
    local Util = require("lazyvim.util")

    return {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        component_separators = "",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", symbols = { modified = "󰳻", readonly = "󰍁", unnamed = "󰡯" } },
          -- stylua: ignore
          {
            function() return require("nvim-navic").get_location() end,
            cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
          },
          -- see: https://github.com/nvim-lualine/lualine.nvim/issues/906
          {
            "%{get(g:, 'coc_status', '')}",
            color = { fg = "#97C379", gui = "bold" },
            icon = { "", align = "left" },
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
            color = Util.fg("Debug"),
          },
          { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = Util.fg("Special") },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
          "encoding",
          "fileformat",
        },
        lualine_y = {
          "progress",
        },
        lualine_z = {
          "location",
        },
      },
      extensions = { "neo-tree", "lazy" },
    }
  end,
}
