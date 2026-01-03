return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1

    -- NOTE: 有一些云数据库的 mysql 版本可能比较老，需要通过过 `brew install mariadb` 安装支持旧版本的 mysql
    -- 同时需要加上 ssl=0 参数，关闭 mysql 的 ssl 加密
    -- vim.g.dbs = {
    --   {
    --     name = "test",
    --     url = "mysql://username:password@host:port/database?ssl=0",
    --   },
    -- }
  end,
}
