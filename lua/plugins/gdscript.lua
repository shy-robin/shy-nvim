return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- LSP 内置于 Godot 编辑器，编辑器必须打开项目才可用
        gdscript = {
          mason = false,
          cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "gdscript", "godot_resource", "gdshader" } },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      dap.adapters.godot = { type = "server", host = "127.0.0.1", port = 6006 }
      dap.configurations.gdscript = {
        {
          type = "godot",
          request = "launch",
          name = "Launch scene",
          project = "${workspaceFolder}",
          launch_scene = true,
        },
      }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = { linters_by_ft = { gdscript = { "gdlint" } } },
  },
}
