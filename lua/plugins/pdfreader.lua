return {
  "r-pletnev/pdfreader.nvim",
  -- snacks.image 用 BufReadCmd 接管 *.pdf 并留下空 buffer，pdfreader 直接往这个 buffer 上
  -- 贴图，因此不能把 pdf 从 snacks.image 的 formats 里摘掉。
  dependencies = { "folke/snacks.nvim" },
  event = { { event = "BufEnter", pattern = "*.pdf" } },
  config = function()
    -- setup 内部是 `opts or default_options`，传空表会把 mode/autosave 变成 nil，
    -- 所以不传参数，交给插件用自己的默认值。
    -- 未装 telescope，:PDFReader showBookmarks/showToc/showRecentBooks 会提示不可用，
    -- 翻页、缩放、视图模式不受影响。
    require("pdfreader").setup()

    -- 插件原本把页码写进窗口局部 statusline，但 lualine 开了 globalstatus，也写同一个
    -- 窗口局部值并按 refresh 间隔覆盖，页码永远不可见。这里改成写进 b:pdfreader_page，
    -- 由 lua/plugins/lualine.lua 里的组件渲染。
    -- 注意这是覆盖上游内部方法 Book:show_statusline，上游改名后页码会静默消失。
    local Book = require("pdfreader.book")
    function Book:show_statusline(bufnr, _)
      if vim.api.nvim_buf_is_valid(bufnr) then
        -- pdfinfo 失败时 number_of_pages 为 nil
        vim.b[bufnr].pdfreader_page = string.format("%s/%s", self.current_page_number, self.number_of_pages or "?")
      end
    end
  end,
}
