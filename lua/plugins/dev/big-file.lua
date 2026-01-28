return {
  "LunarVim/bigfile.nvim",
  event = "BufReadPost",
  opts = {
    pattern = function(bufnr)
      local max_size = 400 * 1024
      local buf_name = vim.api.nvim_buf_get_name(bufnr)
      local file_size = vim.api.nvim_call_function("getfsize", { buf_name })

      if file_size > max_size then
        return true
      end

      -- you can't use `nvim_buf_line_count` because this runs on BufReadPre
      local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
      local file_length = #file_contents
      local max_rows = 5000
      -- local filetype = vim.filetype.match({ buf = bufnr })
      if file_length > max_rows then
        return true
      end

      return false
    end,
  },
}
