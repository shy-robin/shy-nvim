return {
  "hat0uma/csvview.nvim",
  ft = "csv",
  -- BufReadCmd 必须在打开文件之前就注册好，所以放 init 而不是 config。
  init = function()
    vim.api.nvim_create_autocmd("BufReadCmd", {
      group = vim.api.nvim_create_augroup("xlsx_preview", { clear = true }),
      pattern = "*.xlsx",
      callback = function(ev)
        if vim.fn.executable("xlsx2csv") == 0 then
          vim.notify("预览 xlsx 需要 xlsx2csv，装法：pipx install xlsx2csv", vim.log.levels.WARN)
          return
        end
        -- xlsx2csv 是同步跑的，超大表格会卡住 UI，日常预览够用。
        local out = vim.fn.systemlist({ "xlsx2csv", "-a", vim.fn.fnamemodify(ev.file, ":p") })
        if vim.v.shell_error ~= 0 then
          vim.notify("xlsx2csv 失败：" .. table.concat(out, "\n"), vim.log.levels.ERROR)
          return
        end

        -- 重新 :e 时 buffer 还是上一轮设的 nomodifiable，得先放开才能写入。
        vim.bo[ev.buf].modifiable = true
        vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, out)
        -- nowrite + nomodifiable 兜住 :w，否则会把 CSV 文本覆盖回 .xlsx 路径写坏原文件。
        vim.bo[ev.buf].buftype = "nowrite"
        vim.bo[ev.buf].modifiable = false
        vim.bo[ev.buf].modified = false
        vim.bo[ev.buf].filetype = "csv"
      end,
    })
  end,
  opts = {
    -- -a 导出全部 sheet，每个 sheet 前会插一行 `-------- 1 - 名称`。
    -- 当注释处理，这样它既能显示 sheet 名，又不参与列宽对齐。
    parser = { comments = { "#", "//", "--------" } },
    view = { display_mode = "border" },
  },
  config = function(_, opts)
    require("csvview").setup(opts)
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("csvview_auto", { clear = true }),
      pattern = "csv",
      callback = function(ev)
        if not require("csvview").is_enabled(ev.buf) then
          require("csvview").enable(ev.buf)
        end
      end,
    })
  end,
}
