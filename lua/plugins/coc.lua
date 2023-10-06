return {
  "neoclide/coc.nvim",
  branch = 'release',
  event = 'VeryLazy',
  keys = {
    {
      "<c-j>",
      [[coc#pum#visible() ? coc#pum#next(1) : "\<c-j>"]],
      expr = true,
      silent = true,
      desc = "Coc Select Next",
      mode = "i"
    },
    {
      "<c-k>",
      [[coc#pum#visible() ? coc#pum#prev(1) : "\<c-k>"]],
      expr = true,
      silent = true,
      desc = "Coc Select Prev",
      mode = "i"
    },
    {
      "<tab>",
      [[coc#pum#visible() ? coc#pum#confirm() : "\<tab>"]],
      expr = true,
      silent = true,
      desc = "Coc Select cur",
      mode = "i"
    },
    {
      "<c-space>",
      "coc#refresh()",
      expr = true,
      silent = true,
      desc = "Coc Trigger Cmp",
      mode = "i"
    },
    {
      "<c-e>",
      [[coc#pum#visible() ? coc#pum#cancel() : "\<c-e>"]],
      expr = true,
      silent = true,
      desc = "Coc Cancel Cmp",
      mode = "i"
    },
    {
      "gk",
      "<Plug>(coc-diagnostic-prev)",
      silent = true,
      desc = "Coc Prev Diagnostic",
      mode = "n"
    },
    {
      "gj",
      "<Plug>(coc-diagnostic-next)",
      silent = true,
      desc = "Coc Next Diagnostic",
      mode = "n"
    },
    {
      "gd",
      "<Plug>(coc-definition)",
      silent = true,
      desc = "Coc Go definition",
      mode = "n"
    },
    {
      "gt",
      "<Plug>(coc-type-definition)",
      silent = true,
      desc = "Coc Go Type Definition",
      mode = "n"
    },
    {
      "gi",
      "<Plug>(coc-implementation)",
      silent = true,
      desc = "Coc Go Implementation",
      mode = "n"
    },
    {
      "gr",
      "<Plug>(coc-references)",
      silent = true,
      desc = "Coc Go References",
      mode = "n"
    },
    {
      "gh",
      function()
        local cw = vim.fn.expand('<cword>')
        if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
          vim.api.nvim_command('h ' .. cw)
        elseif vim.api.nvim_eval('coc#rpc#ready()') then
          vim.fn.CocActionAsync('doHover')
        else
          vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
        end
      end,
      silent = true,
      desc = "Coc Hover Symbol",
      mode = "n"
    },
    {
      "<leader>fv",
      "<Plug>(coc-format-selected)",
      silent = true,
      desc = "Coc Format Selected",
      mode = { "n", "x" }
    },
    {
      "<leader>rn",
      "<Plug>(coc-rename)",
      silent = true,
      desc = "Coc Rename Symbol",
      mode = { "n" }
    },
    {
      "<leader>ca",
      "<Plug>(coc-codeaction-selected)",
      silent = true,
      nowait = true,
      desc = "Coc Code Action",
      mode = { "n", "x" }
    },
    -- Remap <C-f> and <C-b> to scroll float windows/popups
    {
      "<c-u>",
      'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-u>"',
      expr = true,
      silent = true,
      nowait = true,
      desc = "Coc Scroll Up",
      mode = { "n", "v", "i" }
    },
    {
      "<c-d>",
      'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-d>"',
      expr = true,
      silent = true,
      nowait = true,
      desc = "Coc Scroll Down",
      mode = { "n", "v", "i" }
    },
    {
      "<leader>cd",
      ":<C-u>CocList diagnostics<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Diagnostics",
      mode = "n"
    },
    {
      "<leader>ce",
      ":<C-u>CocList extensions<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Extensions",
      mode = "n"
    },
    {
      "<leader>cc",
      ":<C-u>CocList commands<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Commands",
      mode = "n"
    },
    {
      "<leader>co",
      ":<C-u>CocList outline<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Outline",
      mode = "n"
    },
    {
      "<leader>cs",
      ":<C-u>CocList -I symbols<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Symbols",
      mode = "n"
    },
    {
      "<leader>cj",
      ":<C-u>CocNext<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Next Action",
      mode = "n"
    },
    {
      "<leader>ck",
      ":<C-u>CocPrev<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Prev Action",
      mode = "n"
    },
    {
      "<leader>cp",
      ":<C-u>CocListResume<cr>",
      silent = true,
      nowait = true,
      desc = "CocList Resume",
      mode = "n"
    },
  },
  config = function()
    vim.g.coc_global_extensions = {
      "coc-lua",
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
      "coc-stylua",
      "coc-sumneko-lua",
      "coc-styled-components",
      "coc-svelte",
    }

    -- Some servers have issues with backup files, see #649
    vim.opt.backup = false
    vim.opt.writebackup = false

    -- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
    -- delays and poor user experience
    vim.opt.updatetime = 100

    -- Always show the signcolumn, otherwise it would shift the text each time
    -- diagnostics appeared/became resolved
    vim.opt.signcolumn = "yes"

    local keyset = vim.keymap.set
    -- Autocomplete
    function _G.check_back_space()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
    end

    -- Use <c-j> to trigger snippets
    -- keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")

    -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
    vim.api.nvim_create_augroup("CocGroup", {})
    vim.api.nvim_create_autocmd("CursorHold", {
        group = "CocGroup",
        command = "silent call CocActionAsync('highlight')",
        desc = "Highlight symbol under cursor on CursorHold"
    })

    -- Setup formatexpr specified filetype(s)
    vim.api.nvim_create_autocmd("FileType", {
        group = "CocGroup",
        pattern = "typescript,json",
        command = "setl formatexpr=CocAction('formatSelected')",
        desc = "Setup formatexpr specified filetype(s)."
    })

    -- Update signature help on jump placeholder
    vim.api.nvim_create_autocmd("User", {
        group = "CocGroup",
        pattern = "CocJumpPlaceholder",
        command = "call CocActionAsync('showSignatureHelp')",
        desc = "Update signature help on jump placeholder"
    })

    -- Apply codeAction to the selected region
    -- Example: `<leader>aap` for current paragraph
    local opts = {silent = true, nowait = true}
    keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
    keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

    -- Remap keys for apply code actions at the cursor position.
    keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
    -- Remap keys for apply source code actions for current file.
    keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
    -- Apply the most preferred quickfix action on the current line.
    keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

    -- Remap keys for apply refactor code actions.
    keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
    keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
    keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

    -- Run the Code Lens actions on the current line
    keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)


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
    keyset("n", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
    keyset("x", "<C-s>", "<Plug>(coc-range-select)", {silent = true})


    -- Add `:Format` command to format current buffer
    vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

    -- " Add `:Fold` command to fold current buffer
    vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})

    -- Add `:OR` command for organize imports of the current buffer
    vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

    -- Add (Neo)Vim's native statusline support
    -- NOTE: Please see `:h coc-status` for integrations with external plugins that
    -- provide custom statusline: lightline.vim, vim-airline
    vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
  end
}
