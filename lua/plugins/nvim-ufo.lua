-- https://github.com/kevinhwang91/nvim-ufo/issues/117

-- Adding number suffix of folded lines instead of the default ellipsis
local handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (" 󰁂 %d "):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  event = "BufRead",
  opts = {
    filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
  },
  keys = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
    },
    -- 注意不要设置为 K，因为会被 LazyVim 设置的 K 覆盖
    -- TODO: conflict with coc
    {
      "gp",
      function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end,
      desc = "Preview Fold",
    },
  },
  config = function()
    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    -- 不需要设置，否则会有多余的间隙
    -- vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- 清除折叠侧边栏所在列的高亮
    vim.api.nvim_set_hl(0, "FoldColumn", {})
    -- 高亮折叠的行
    vim.api.nvim_set_hl(0, "Folded", { bg = "#01579B" })

    require("ufo").setup({
      enable_get_fold_virt_text = true,
      open_fold_hl_timeout = 150,
      preview = {
        win_config = {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
        mappings = {
          -- TODO: conflict with coc
          -- scrollU = '<C-u>',
          -- scrollD = '<C-d>',
          jumpTop = "[",
          jumpBot = "]",
        },
      },
      fold_virt_text_handler = handler,
    })
  end,
}
