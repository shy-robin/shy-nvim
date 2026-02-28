return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.terminal = opts.terminal or {}
    opts.terminal.enabled = true
    return opts
  end,
  keys = {
    -- Switch terminal using picker
    {
      "<leader>t,",
      function()
        require("snacks.picker").pick({
          source = "terminals",
          format = function(item)
            local terminal = item.terminal
            local id = vim.b[terminal.buf].snacks_terminal and vim.b[terminal.buf].snacks_terminal.id or "N/A"
            -- 获取终端的工作目录，优先从 terminal 对象的 opts 中获取
            local cwd = "unknown"
            if terminal.opts and terminal.opts.cwd then
              cwd = terminal.opts.cwd
            elseif vim.api.nvim_buf_is_valid(terminal.buf) then
              -- 尝试从 buffer 获取 cwd
              local success, buf_cwd = pcall(function()
                return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(terminal.buf), ":h")
              end)
              if success and buf_cwd and buf_cwd ~= "" then
                cwd = buf_cwd
              else
                cwd = "/"
              end
            end
            local is_current = terminal.buf == vim.api.nvim_get_current_buf()
            local current_mark = is_current and " (current)" or ""
            return {
              { "Terminal #" .. id, hl = "Title" },
              { " " },
              { cwd, hl = "Comment" },
              { current_mark, hl = "Special" },
            }
          end,
          finder = function()
            local terminals = Snacks.terminal.list()
            if #terminals == 0 then
              vim.notify("No active terminals found", vim.log.levels.WARN)
              return {}
            end
            local items = {}
            for _, terminal in ipairs(terminals) do
              if vim.bo[terminal.buf].filetype == "snacks_terminal" then
                table.insert(items, {
                  terminal = terminal,
                  text = "",
                })
              end
            end
            return items
          end,
          actions = {
            confirm = function(picker, item)
              if item and item.terminal then
                if item.terminal:valid() then
                  -- 窗口有效，直接聚焦
                  item.terminal:focus()
                else
                  -- 窗口已关闭，重新显示
                  item.terminal:show()
                end
              end
            end,
          },
        })
      end,
      desc = "Switch Terminal",
    },
    -- Terminal mode keymaps for snacks terminal
    -- Ctrl+n: 新建底部终端
    {
      mode = "t",
      "<C-n>",
      function()
        if vim.bo.filetype ~= "snacks_terminal" then
          return
        end
        -- 获取当前终端的 ID
        local current_id = vim.b.snacks_terminal and vim.b.snacks_terminal.id or 0
        -- 新建 ID 为当前 ID + 1 的终端
        Snacks.terminal.open(nil, { cwd = LazyVim.root(), count = current_id + 1 })
      end,
      desc = "New Bottom Terminal",
    },
    -- Ctrl+h: 上一个底部终端
    {
      mode = "t",
      "<C-h>",
      function()
        if vim.bo.filetype ~= "snacks_terminal" then
          return
        end
        local term_list = Snacks.terminal.list()
        if #term_list == 0 then
          return
        end

        local current_id = vim.b.snacks_terminal and vim.b.snacks_terminal.id or 1
        local prev_id = current_id - 1

        -- 收集所有终端的 ID
        local ids = {}
        for _, t in ipairs(term_list) do
          local id = vim.b[t.buf].snacks_terminal and vim.b[t.buf].snacks_terminal.id or 0
          table.insert(ids, id)
        end

        table.sort(ids)
        local max_id = ids[#ids]

        -- 如果已经是第一个，跳到最后一个
        if prev_id < 1 then
          prev_id = max_id
        end

        -- 找到并显示上一个终端
        for _, t in ipairs(term_list) do
          local id = vim.b[t.buf].snacks_terminal and vim.b[t.buf].snacks_terminal.id or 0
          if id == prev_id then
            t:show()
            break
          end
        end
      end,
      desc = "Prev Bottom Terminal",
    },
    -- Ctrl+l: 下一个底部终端
    {
      mode = "t",
      "<C-l>",
      function()
        if vim.bo.filetype ~= "snacks_terminal" then
          return
        end
        local term_list = Snacks.terminal.list()
        if #term_list == 0 then
          return
        end

        local current_id = vim.b.snacks_terminal and vim.b.snacks_terminal.id or 0
        local next_id = current_id + 1

        -- 收集所有终端的 ID
        local ids = {}
        for _, t in ipairs(term_list) do
          local id = vim.b[t.buf].snacks_terminal and vim.b[t.buf].snacks_terminal.id or 0
          table.insert(ids, id)
        end

        table.sort(ids)
        local max_id = ids[#ids]

        -- 如果已经是最后一个，跳到第一个
        if next_id > max_id then
          next_id = 1
        end

        -- 找到并显示下一个终端
        for _, t in ipairs(term_list) do
          local id = vim.b[t.buf].snacks_terminal and vim.b[t.buf].snacks_terminal.id or 0
          if id == next_id then
            t:show()
            break
          end
        end
      end,
      desc = "Next Bottom Terminal",
    },
    -- Ctrl+q: 关闭当前底部终端
    {
      mode = "t",
      "<C-q>",
      function()
        if vim.bo.filetype ~= "snacks_terminal" then
          return
        end
        vim.cmd("q")
      end,
      desc = "Close Bottom Terminal",
    },
  },
}

