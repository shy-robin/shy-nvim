local servers = {
  vtsls = {
    settings = {
      typescript = {
        inlayHints = {
          enumMemberValues = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          parameterNames = { enabled = "all" },
          variableTypes = { enabled = false },
        },
      },
      javascript = {
        inlayHints = {
          enumMemberValues = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          parameterNames = { enabled = "all" },
          variableTypes = { enabled = false },
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        workspace = {
          checkThirdParty = false,
        },
        completion = {
          callSnippet = "Replace",
        },
        doc = {
          privateName = { "^_" },
        },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
      },
    },
  },
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = true,
        },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = {
          nilness = true,
          unusedparams = true,
          unusedwrite = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = {
          "-.git",
          "-.vscode",
          "-node_modules",
          "-.vendor",
        },
        semanticTokens = true,
      },
    },
  },
}

return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = vim.tbl_deep_extend("force", {}, opts.servers or {}, servers)

    -- LazyVim 16 still enables analyzers removed from current gopls.
    local analyses = vim.tbl_get(opts, "servers", "gopls", "settings", "gopls", "analyses")
    if analyses then
      analyses.fieldalignment = nil
      analyses.useany = nil
    end
  end,
}
