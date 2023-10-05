return {
  "luukvbaal/statuscol.nvim",
  event = "BufEnter",
  config = function()
    local builtin = require("statuscol.builtin")

    require("statuscol").setup({
      relculright = true,
      ft_ignore = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
        "floaterm"
      },
      segments = {
        { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
        {
          sign = {
            name = { "Diagnostic" },
            -- 最多展示 sign 的数量
            maxwidth = 1,
            auto = false,
            wrap = false,
            -- 当没有 sign 时的占位符
            fillchar = " "
          },
          click = "v:lua.ScSa",
        },
        { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        {
          sign = {
            name = { ".*" },
            maxwidth = 1,
            colwidth = 1,
            auto = false,
            wrap = false,
            fillchar = " "
          },
          click = "v:lua.ScSa"
        }
      },
    })
  end,
}
