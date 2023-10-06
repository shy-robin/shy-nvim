-- 配置参考：https://www.ejmastnak.com/tutorials/vim-latex/luasnip/#tips

return {
  "L3MON4D3/LuaSnip",
  event = "InsertEnter",
  -- opts 会自动和 LazyVim 的默认配置合并
  opts = {
    -- 当有重复 node 时，输入的内容会同步更新
    update_events = { "TextChanged", "TextChangedI" },
    -- 使用 tab 键存储 visual 选中的内容
    store_selection_keys = "<tab>",
    enable_autosnippets = true,
  },
  keys = function()
    return {
      {
        "<C-l>",
        function()
          local ls = require("luasnip")
          if ls.jumpable(1) then
            ls.jump(1)
          end
        end,
        -- for INSERT and SELECT mode
        mode = { "i", "s" },
      },
      -- TODO: conflict with coc
      -- {
      --   "<C-k>",
      --   function()
      --     local ls = require("luasnip")
      --     if ls.jumpable(-1) then
      --       ls.jump(-1)
      --     end
      --   end,
      --   -- for INSERT and SELECT mode
      --   mode = { "i", "s" },
      -- },
  }
  end,
  config = function(_, opts)
    require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/lua/snippets" })
    -- config 函数默认会将 opts 传入插件的 setup 函数里；
    -- 因为重写了 config 函数，所以需要将 opts 传入 setup 里；
    require("luasnip").setup(opts)
  end,
}
