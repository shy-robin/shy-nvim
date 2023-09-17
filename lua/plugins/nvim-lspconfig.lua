return {
  "neovim/nvim-lspconfig",
  init = function()
    local format = function()
      require("lazyvim.plugins.lsp.format").format({ force = true })
    end

    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- change a keymap
    -- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
    keys[#keys + 1] = { "gh", vim.lsp.buf.hover, desc = "Hover" }
    keys[#keys + 1] = { "gj", "]d", desc = "Next Diagnostic", remap = true }
    keys[#keys + 1] = { "gk", "[d", desc = "Prev Diagnostic", remap = true }
    keys[#keys + 1] = { "gl", vim.diagnostic.open_float, desc = "Line Diagnostics" }
    keys[#keys + 1] = { "gne", "]e", desc = "Next Error", remap = true }
    keys[#keys + 1] = { "gNe", "[e", desc = "Prev Error", remap = true }
    keys[#keys + 1] = { "gnw", "]w", desc = "Next Warning", remap = true }
    keys[#keys + 1] = { "gNw", "[w", desc = "Prev Warning", remap = true }
    keys[#keys + 1] = { "<leader>fm", format, desc = "Format Document", has = "formatting" }
    keys[#keys + 1] = { "<leader>fm", format, desc = "Format Range", mode = "v", has = "rangeFormatting" }
    keys[#keys + 1] = { "<leader>rn", "<leader>cr", desc = "Rename", remap = true }
  end,
}
