return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 500,
    },
    -- 覆盖默认配置，使其能出现在 sign list 中
    -- see: https://github.com/lewis6991/gitsigns.nvim/issues/902
    -- _extmark_signs = false,
    signs = {
      delete = { text = "󰘡" },
      topdelete = { text = "󰘣" },
    },
    current_line_blame_formatter = "(<author> <author_time:%R>) <summary>",
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      -- stylua: ignore start
      map("n", "<leader>gj", gs.next_hunk, "Next Hunk")
      map("n", "<leader>gk", gs.prev_hunk, "Prev Hunk")
      map({ "n", "v" }, "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Stage Hunk", silent = true })
      map({ "n", "v" }, "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset Hunk", silent = true })
      map("n", "<leader>ghS", gs.stage_buffer, { desc = "Stage Buffer", silent = true })
      map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk", silent = true })
      map("n", "<leader>ghR", gs.reset_buffer, { desc = "Reset Buffer", silent = true })
      map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
      map("n", "<leader>ghd", gs.diffthis, "Diff This")
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
      -- 选择 hunk
      -- yih 复制 hunk 内容
      -- vih 选中 hunk 内容
      -- 其中，o 对应 operator-pending 模式，x 对应 visual 模式
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")

      -- sign color
      local hl = vim.api.nvim_set_hl

      hl(0, "GitSignsAdd", { fg = "#0EAA00"  })
      hl(0, "GitSignsChange", { fg = "#E5C07B"  })
      hl(0, "GitSignsDelete", { fg = "#E06C75"  })
      hl(0, "GitSignsTopdelete", { fg = "#E06C75"  })
      hl(0, "GitSignsChangedelete", { fg = "#E5C07B"  })
      hl(0, "GitSignsUntracked", { fg = "#E06C75"  })
      hl(0, 'GitsignsCurrentLineBlame', { fg = "#62686E"  })
    end,
  },
}
