return {
  "neoclide/coc.nvim",
  branch = "release",
  event = "VeryLazy",
  keys = {
    {
      "<c-j>",
      [[coc#pum#visible() ? coc#pum#next(1) : "\<c-j>"]],
      expr = true,
      silent = true,
      desc = "Coc Select Next",
      mode = "i",
    },
    {
      "<c-k>",
      [[coc#pum#visible() ? coc#pum#prev(1) : "\<c-k>"]],
      expr = true,
      silent = true,
      desc = "Coc Select Prev",
      mode = "i",
    },
    {
      "<tab>",
      [[coc#pum#visible() ? coc#pum#confirm() : "\<tab>"]],
      expr = true,
      silent = true,
      desc = "Coc Select Cur",
      mode = "i",
    },
    {
      "<c-f>",
      "<Plug>(coc-snippets-expand-jump)",
      silent = true,
      desc = "Coc Snippet Expand Or Jump",
      mode = "i",
    },
    -- visual mode 下，按下 Tab 键选中文本（参考 UltiSnips 的 Visual Placeholder）
    -- 使用 ctrl-i 同样能触发
    {
      "<tab>",
      "<Plug>(coc-snippets-select)",
      silent = true,
      desc = "Coc Snippet Select",
      mode = "v",
    },
    {
      "<c-space>",
      "coc#refresh()",
      expr = true,
      silent = true,
      desc = "Coc Trigger Cmp",
      mode = "i",
    },
    {
      "<c-e>",
      [[coc#pum#visible() ? coc#pum#cancel() : "\<c-e>"]],
      expr = true,
      silent = true,
      desc = "Coc Cancel Cmp",
      mode = "i",
    },
    {
      "gk",
      "<Plug>(coc-diagnostic-prev)",
      silent = true,
      desc = "Coc Prev Diagnostic",
      mode = "n",
    },
    {
      "gj",
      "<Plug>(coc-diagnostic-next)",
      silent = true,
      desc = "Coc Next Diagnostic",
      mode = "n",
    },
    {
      "gd",
      "<Plug>(coc-definition)",
      silent = true,
      desc = "Coc Go definition",
      mode = "n",
    },
    {
      "gt",
      "<Plug>(coc-type-definition)",
      silent = true,
      desc = "Coc Go Type Definition",
      mode = "n",
    },
    {
      "gi",
      "<Plug>(coc-implementation)",
      silent = true,
      desc = "Coc Go Implementation",
      mode = "n",
    },
    {
      "gr",
      "<Plug>(coc-references)",
      silent = true,
      desc = "Coc Go References",
      mode = "n",
    },
    {
      "gh",
      function()
        local cw = vim.fn.expand("<cword>")

        -- 否则，唤起浮动窗口
        if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
          vim.api.nvim_command("h " .. cw)
        elseif vim.api.nvim_eval("coc#rpc#ready()") then
          vim.fn.CocActionAsync("doHover")
        else
          vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
        end
      end,
      silent = true,
      desc = "Coc Hover Symbol",
      mode = "n",
    },
    {
      "gw",
      function()
        -- 如果当前光标在浮动窗口内，则将浮动窗口关闭（也可以使用 <C-w><C-w> 跳转）
        if vim.api.nvim_win_get_config(0).zindex then
          vim.api.nvim_command("call coc#float#close_all()")
          return
        end

        -- 如果当前窗口内有浮动窗口，则将光标移动到浮动窗口内（也可以使用 <C-w><C-w> 跳转）
        for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_get_config(winid).zindex then
            vim.api.nvim_command("call coc#float#jump()")
            return
          end
        end
      end,
      silent = true,
      desc = "Coc Focus Float Window",
      mode = "n",
    },
    {
      "<leader>fv",
      "<Plug>(coc-format-selected)",
      silent = true,
      desc = "Coc Format Selected",
      mode = { "n", "x" },
    },
    {
      "<leader>rn",
      "<Plug>(coc-rename)",
      silent = true,
      desc = "Coc Rename Symbol",
      mode = { "n" },
    },
    -- Apply codeAction to the selected region
    -- Example: `<leader>aap` for current paragraph
    {
      "<leader>cav",
      "<Plug>(coc-codeaction-selected)",
      silent = true,
      nowait = true,
      desc = "Coc Code Action Selected",
      mode = { "n", "x" },
    },
    -- Remap keys for apply code actions at the cursor position.
    {
      "<leader>caa",
      "<Plug>(coc-codeaction-cursor)",
      silent = true,
      nowait = true,
      desc = "Coc Code Action Cursor",
      mode = "n",
    },
    -- Remap keys for apply source code actions for current file.
    {
      "<leader>caf",
      "<Plug>(coc-codeaction-source)",
      silent = true,
      nowait = true,
      desc = "Coc Code Action File",
      mode = "n",
    },
    -- Apply the most preferred quickfix action on the current line.
    {
      "<leader>qf",
      "<Plug>(coc-fix-current)",
      silent = true,
      nowait = true,
      desc = "Coc Quick Fix",
      mode = "n",
    },
    -- Run the Code Lens actions on the current line
    {
      "<leader>Cl",
      "<Plug>(coc-codelens-action)",
      silent = true,
      nowait = true,
      desc = "Coc Code Lens",
      mode = "n",
    },
    -- Remap keys for apply refactor code actions.
    {
      "<leader>re",
      "<Plug>(coc-codeaction-refactor)",
      silent = true,
      desc = "Coc Refactor",
      mode = "n",
    },
    {
      "<leader>r",
      "<Plug>(coc-codeaction-refactor-selected)",
      silent = true,
      desc = "Coc Refactor",
      mode = { "n", "x" },
    },
    -- Remap <C-f> and <C-b> to scroll float windows/popups
    {
      "<c-u>",
      'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-u>"',
      expr = true,
      silent = true,
      nowait = true,
      desc = "Coc Scroll Up",
      mode = { "n", "v", "i" },
    },
    {
      "<c-d>",
      'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-d>"',
      expr = true,
      silent = true,
      nowait = true,
      desc = "Coc Scroll Down",
      mode = { "n", "v", "i" },
    },
    {
      "<leader>cd",
      ":<C-u>CocList diagnostics<cr>",
      silent = true,
      nowait = true,
      desc = "Diagnostics (CocList)",
      mode = "n",
    },
    {
      "<leader>Ce",
      ":<C-u>CocList extensions<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Extensions",
      mode = "n",
    },
    {
      "<leader>Cc",
      ":<C-u>CocList commands<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Commands",
      mode = "n",
    },
    {
      "<leader>Co",
      ":<C-u>CocList outline<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Outline",
      mode = "n",
    },
    {
      "<leader>Cm",
      ":<C-u>CocList marketplace<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Marketplace",
      mode = "n",
    },
    {
      "<leader>Cs",
      ":<C-u>CocList -I symbols<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Symbols",
      mode = "n",
    },
    {
      "<leader>csc",
      "<Plug>(coc-convert-snippet)",
      silent = true,
      nowait = true,
      desc = "Convert (Coc Snippets)",
      mode = "x",
    },
    {
      "<leader>csl",
      ":<C-u>CocList snippets<cr>",
      silent = true,
      nowait = true,
      desc = "List (Coc Snippets)",
      mode = "n",
    },
    {
      "<leader>csf",
      ":<C-u>CocCommand snippets.openSnippetFiles<cr>",
      silent = true,
      nowait = true,
      desc = "Files (Coc Snippets)",
      mode = "n",
    },
    {
      "<leader>cse",
      ":<C-u>CocCommand snippets.editSnippets<cr>",
      silent = true,
      nowait = true,
      desc = "Edit (Coc Snippets)",
      mode = "n",
    },
    {
      "<leader>cso",
      ":<C-u>CocCommand snippets.openOutput<cr>",
      silent = true,
      nowait = true,
      desc = "Output (Coc Snippets)",
      mode = "n",
    },
    {
      "<leader>Cj",
      ":<C-u>CocNext<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Next Action",
      mode = "n",
    },
    {
      "<leader>Ck",
      ":<C-u>CocPrev<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Prev Action",
      mode = "n",
    },
    {
      "<leader>Cp",
      ":<C-u>CocListResume<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Resume",
      mode = "n",
    },
    {
      "<cr>",
      -- coc enter 会在标签内换行后自动缩进
      -- see：https://www.reddit.com/r/neovim/comments/k530h1/auto_indent_in_html_files_on_new_lines_after/
      [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
      expr = true,
      silent = true,
      desc = "Coc Enter",
      mode = "i",
    },
    {
      "<leader>fa",
      "<cmd>CocCommand eslint.executeAutofix<cr>",
      silent = true,
      desc = "Coc Eslint Auto Fix",
      mode = "n",
    },
    {
      "<leader>CR",
      "<cmd>CocRestart<cr>",
      silent = true,
      nowait = true,
      desc = "Coc Restart",
      mode = "n",
    },
    -- {
    --   "gom",
    --   "<cmd>CocCommand markdown-preview-enhanced.openPreview<cr>",
    --   silent = true,
    --   nowait = true,
    --   desc = "Coc Markdown Preview",
    --   mode = "n",
    -- },
    -- {
    --   "<leader>cy",
    --   "<cmd>CocList -A --normal yank<cr>",
    --   silent = true,
    --   nowait = true,
    --   desc = "Coc Yank List",
    --   mode = "n",
    -- },
    {
      "<leader>ct",
      "<Plug>(coc-translator-p)",
      silent = true,
      nowait = true,
      desc = "Coc Translator Popup",
      mode = "n",
    },
    {
      "<leader>ct",
      "<Plug>(coc-translator-pv)",
      silent = true,
      nowait = true,
      desc = "Coc Translator Popup",
      mode = "v",
    },
    {
      "<leader>Ctp",
      "<Plug>(coc-translator-p)",
      silent = true,
      nowait = true,
      desc = "Coc Translator Popup",
      mode = "n",
    },
    {
      "<leader>Ctp",
      "<Plug>(coc-translator-pv)",
      silent = true,
      nowait = true,
      desc = "Coc Translator Popup",
      mode = "v",
    },
    {
      "<leader>Cte",
      "<Plug>(coc-translator-e)",
      silent = true,
      nowait = true,
      desc = "Coc Translator Echo",
      mode = "n",
    },
    {
      "<leader>Cte",
      "<Plug>(coc-translator-ev)",
      silent = true,
      nowait = true,
      desc = "Coc Translator Echo",
      mode = "v",
    },
    {
      "<leader>Ctr",
      "<Plug>(coc-translator-r)",
      silent = true,
      nowait = true,
      desc = "Coc Translator Replace",
      mode = "n",
    },
    {
      "<leader>Ctr",
      "<Plug>(coc-translator-rv)",
      silent = true,
      nowait = true,
      desc = "Coc Translator Replace",
      mode = "v",
    },
    {
      "<leader>Ctl",
      ":<C-u>CocList translation<cr>",
      silent = true,
      nowait = true,
      desc = "Coc Translator List",
      mode = "n",
    },
    -- {
    --   "<c-y>",
    --   "<Plug>(coc-cursors-word)*",
    --   silent = true,
    --   desc = "Coc Eslint Auto Fix",
    --   mode = "n",
    -- },
    -- {
    --   "<c-y>",
    --   "y/V<C-r>=escape(@\",'/\')<CR><CR>gN<Plug>(coc-cursors-range)gn",
    --   expr = true,
    --   silent = true,
    --   desc = "Coc Eslint Auto Fix",
    --   mode = "x",
    -- },
    -- nmap <silent> <C-c> <Plug>(coc-cursors-position)
    -- nmap <silent> <C-d> <Plug>(coc-cursors-word)
    -- xmap <silent> <C-d> <Plug>(coc-cursors-range)
    -- " use normal command like `<leader>xi(`
    -- nmap <leader>x  <Plug>(coc-cursors-operator)
  },
  config = function()
    vim.g.coc_global_extensions = {
      "coc-lua",
      -- 注意，如果有找不到 stylua 文件夹的报错，需要手动创建 stylua 数据文件夹：/home/shyrobin/.config/coc/extensions/coc-stylua-data/stylua
      "coc-stylua",
      "coc-json",
      "coc-marketplace",
      "coc-spell-checker",
      "coc-html",
      "coc-css",
      "coc-emmet",
      "coc-prettier",
      "@yaegassy/coc-volar",
      "coc-tsserver",
      "coc-cssmodules",
      "coc-diagnostic",
      "coc-eslint",
      "coc-htmlhint",
      "coc-html-css-support",
      "coc-sumneko-lua",
      "coc-styled-components",
      "coc-svelte",
      "coc-pairs",
      "coc-snippets",
      "coc-markdownlint",
      "coc-flutter",
      -- "coc-markdown-preview-enhanced",
      -- "coc-yank",
      -- "coc-webview",
      "coc-translator",
      "@yaegassy/coc-tailwindcss3",
    }

    -- Some servers have issues with backup files, see #649
    vim.opt.backup = false
    vim.opt.writebackup = false

    -- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
    -- delays and poor user experience
    vim.opt.updatetime = 100

    -- Always show the signcolumn, otherwise it would shift the text each time
    -- diagnostics appeared/became resolved
    -- NOTE: 设置这个会导致 dashboard 变化
    -- vim.opt.signcolumn = "yes"

    -- coc snippets
    vim.g.coc_snippet_next = "<c-l>"
    vim.g.coc_snippet_prev = "<c-h>"

    -- coc-snippets 中 utlisnips 会用到的一些变量
    vim.g.snips_author = "ShyRobin"
    vim.g.snips_author_email = "shy_robin@163.com"

    local keyset = vim.keymap.set
    -- Autocomplete
    function _G.check_back_space()
      local col = vim.fn.col(".") - 1
      return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
    end

    -- Use <c-j> to trigger snippets
    -- keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")

    -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
    vim.api.nvim_create_augroup("CocGroup", {})
    vim.api.nvim_create_autocmd("CursorHold", {
      group = "CocGroup",
      command = "silent call CocActionAsync('highlight')",
      desc = "Highlight symbol under cursor on CursorHold",
    })

    -- Setup formatexpr specified filetype(s)
    vim.api.nvim_create_autocmd("FileType", {
      group = "CocGroup",
      pattern = "typescript,json",
      command = "setl formatexpr=CocAction('formatSelected')",
      desc = "Setup formatexpr specified filetype(s).",
    })

    -- Update signature help on jump placeholder
    vim.api.nvim_create_autocmd("User", {
      group = "CocGroup",
      pattern = "CocJumpPlaceholder",
      command = "call CocActionAsync('showSignatureHelp')",
      desc = "Update signature help on jump placeholder",
    })

    local opts = { silent = true, nowait = true }

    -- Map function and class text objects
    -- NOTE: Requires 'textDocument.documentSymbol' support from the language server
    keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
    keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
    keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
    keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
    keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
    keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
    keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
    keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)

    -- Use CTRL-S for selections ranges
    -- Requires 'textDocument/selectionRange' support of language server
    keyset("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true })
    keyset("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })

    -- Add `:Format` command to format current buffer
    vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

    -- " Add `:Fold` command to fold current buffer
    vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = "?" })

    -- Add `:OR` command for organize imports of the current buffer
    vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

    -- Add (Neo)Vim's native statusline support
    -- NOTE: Please see `:h coc-status` for integrations with external plugins that
    -- provide custom statusline: lightline.vim, vim-airline
    vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

    -- 切换 coc 的状态
    Snacks.toggle({
      name = "Coc",
      get = function()
        if vim.g.is_coc_enabled == nil then
          vim.g.is_coc_enabled = vim.g.coc_process_pid and vim.g.coc_process_pid ~= 0
        end
        return vim.g.is_coc_enabled
      end,
      set = function(enabled)
        if enabled then
          vim.api.nvim_command("CocEnable")
          vim.g.is_coc_enabled = true
        else
          vim.api.nvim_command("CocDisable")
          vim.g.is_coc_enabled = false
        end
      end,
    }):map("<leader>CC")
  end,
}
