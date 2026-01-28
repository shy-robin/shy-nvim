function get_format_time()
  -- 获取当前时间戳
  local timestamp = os.time()
  -- 将时间戳转换为本地时间字符串
  local local_time = os.date("%Y-%m-%d %H:%M:%S", timestamp)
  -- 获取当前是周几的文本表示（例如 "Mon"）
  local week = os.date("%A")

  return ("%s %s"):format(local_time, week)
end

function get_user_title()
  -- 获取当前用户名称，兼容不同操作系统
  local username
  if package.config:sub(1, 1) == "\\" then
    -- Windows系统
    username = os.getenv("USERNAME")
  else
    -- Unix-like系统
    username = os.getenv("USER")
  end
  local time = get_format_time()
  local user_title = ("  %s (%s)\n\n"):format(username, time)

  return user_title
end

function get_robot_title()
  local robot_name = "Assistant"
  local time = get_format_time()
  local robot_title = ("󱙺  %s (%s)\n\n"):format(robot_name, time)

  return robot_title
end

return {
  "Kurama622/llm.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
  cmd = { "LLMSesionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
  config = function()
    local tools = require("llm.tools")

    local userTitle = get_user_title()
    local robotTitle = get_robot_title()

    require("llm").setup({
      max_tokens = 512,
      url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
      model = "glm-4-flash",
      prefix = {
        user = { text = userTitle, hl = "Title" },
        assistant = { text = robotTitle, hl = "Added" },
      },
      style = "right",

      save_session = true,
      max_history = 15,

      keys = {
        -- The keyboard mapping for the input window.
        ["Input:Submit"] = { mode = "n", key = "<cr>" },
        ["Input:Cancel"] = { mode = "n", key = "<C-c>" },
        ["Input:Resend"] = { mode = "n", key = "<C-r>" },

        -- only works when "save_session = true"
        ["Input:HistoryNext"] = { mode = "n", key = "<C-j>" },
        ["Input:HistoryPrev"] = { mode = "n", key = "<C-k>" },

        -- The keyboard mapping for the output window in "split" style.
        ["Output:Ask"] = { mode = "n", key = "i" },
        ["Output:Cancel"] = { mode = "n", key = "<C-c>" },
        ["Output:Resend"] = { mode = "n", key = "<C-r>" },

        -- The keyboard mapping for the output and input windows in "float" style.
        ["Session:Toggle"] = { mode = "n", key = "<leader>ac" },
        ["Session:Close"] = { mode = "n", key = "<esc>" },
      },

      spinner = {
        text = {
          "",
          "",
          "",
          "",
        },
        hl = "Title",
      },
      app_handler = {
        OptimizeCode = {
          handler = tools.side_by_side_handler,
        },
        OptimCompare = {
          handler = tools.action_handler,
        },
        Translate = {
          handler = tools.qa_handler,
        },
        FlexibleTranslate = {
          handler = tools.flexi_handler,
          prompt = "如果下列文案是中文那么把它翻译成英文，如果是英文或者其他语言则翻译成中文，请只返回翻译结果。",
          opts = {
            exit_on_move = false,
            enter_flexible_window = true,
          },
        },
        CommitMsg = {
          handler = tools.flexi_handler,
          prompt = function()
            return string.format(
              [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:
                1. Start with an action verb (e.g., feat, fix, refactor, chore, etc.), followed by a colon.
                2. Briefly mention the file or module name that was changed.
                3. Describe the specific changes made.

                Examples:
                - feat: update common/util.py, added test cases for util.py
                - fix: resolve bug in user/auth.py related to login validation
                - refactor: optimize database queries in models/query.py

                Based on this format, generate appropriate commit messages. Respond with message only. DO NOT format the message in Markdown code blocks, DO NOT use backticks:

                ```diff
                %s
                ```
              ]],
              vim.fn.system("git diff --no-ext-diff --staged")
            )
          end,

          opts = {
            enter_flexible_window = true,
            apply_visual_selection = false,
            win_opts = {
              relative = "editor",
              position = "50%",
            },
            accept = {
              mapping = {
                mode = "n",
                keys = "<cr>",
              },
              action = function()
                local contents = vim.api.nvim_buf_get_lines(0, 0, -1, true)
                vim.api.nvim_command(string.format('!git commit -m "%s"', table.concat(contents)))

                -- just for lazygit
                vim.schedule(function()
                  vim.api.nvim_command("LazyGit")
                end)
              end,
            },
          },
        },
      },
    })
  end,
  keys = {
    { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>", desc = "Chat" },
    { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>", desc = "Explain" },
    -- {
    --   "<leader>at",
    --   mode = "x",
    --   "<cmd>LLMSelectedTextHandler 如果是英文则翻译成中文，如果是中文则翻译成英文<cr>",
    --   desc = "Translate",
    -- },
    { "<leader>at", mode = "x", "<cmd>LLMAppHandler FlexibleTranslate<cr>", desc = "Translate" },
    { "<leader>aT", mode = "n", "<cmd>LLMAppHandler Translate<cr>", desc = "Translator" },
    -- 浮动窗口优化代码。按 y 键复制优化后的代码，按 n 键忽略。
    { "<leader>ao", mode = "x", "<cmd>LLMAppHandler OptimizeCode<cr>", desc = "Optimize Code in Float" },
    -- diff 窗口优化代码。按 y 键接受建议，按 n 键忽略。
    { "<leader>aO", mode = "x", "<cmd>LLMAppHandler OptimCompare<cr>", desc = "Optimize Code in Split" },
    { "<leader>ag", mode = "n", "<cmd>LLMAppHandler CommitMsg<cr>", desc = "Commit Message" },
  },
}
