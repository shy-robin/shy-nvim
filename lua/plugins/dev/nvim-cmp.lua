return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-cmdline",
    "f3fora/cmp-spell"
  },
  opts = function()
    local defaults = require("cmp.config.default")()
    local cmp = require("cmp")

    -- `/` cmdline setup.
    ---@diagnostic disable-next-line: missing-fields
    cmp.setup.cmdline('/', {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- `:` cmdline setup.
    ---@diagnostic disable-next-line: missing-fields
    cmp.setup.cmdline(':', {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        {
          name = 'cmdline',
          option = {
            ignore_cmds = { 'Man', '!' }
          }
        }
      })
    })

    return {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      -- see: https://github.com/f3fora/cmp-spell/issues/10
      preselect = cmp.PreselectMode.None,
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<S-CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 10 },
        { name = "luasnip",  priority = 8 },
        { name = "buffer",   priority = 6 },
        { name = "spell",    priority = 4 },
        { name = "path",     priority = 2 },
      }),
      formatting = {
        format = function(entry, item)
          local icons = require("lazyvim.config").icons.kinds
          if icons[item.kind] then
            item.kind = icons[item.kind] .. item.kind
            item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              spell = "[Spell]",
              path = "[Path]"
            })[entry.source.name]
          end
          return item
        end,
      },
      sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.locality,
          cmp.config.compare.recently_used,
          cmp.config.compare.score, -- final_score = orig_score + ((#sources - (source_index - 1)) * sorting.priority_weight) (priority_weight = sources[n].priority
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          -- cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          -- cmp.config.compare.length,
          -- cmp.config.compare.order,
        },
      },
    }
  end,
}
