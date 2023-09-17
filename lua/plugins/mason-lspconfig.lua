return {
  "williamboman/mason-lspconfig.nvim",
  config = function()
    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          local server_config = {}
          if require("neoconf").get(server_name .. ".disable") then
            return
          end
          if server_name == "volar" then
            server_config.filetypes = { "vue", "typescript", "javascript" }
          end
          require("lspconfig")[server_name].setup(server_config)
        end,
      },
    })
  end,
}
