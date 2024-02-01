return {
  "mfussenegger/nvim-dap",
  lazy = true,
  dependencies = {
    -- mason.nvim integration
    -- vscode-js-debug 安装构建会报错，所以使用 mason 安装 js adapter
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason.nvim",
      cmd = { "DapInstall", "DapUninstall" },
      opts = {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          -- 指定这个版本，不然无法调试，参考：https://github.com/mxsdev/nvim-dap-vscode-js/issues/31#issuecomment-1676971275
          "js@v1.76.1",
        },
      },
    },

    -- for Javascript / Typescript
    {
      "mxsdev/nvim-dap-vscode-js",
      -- vscode-js-debug 安装不了，所以使用 mason 安装 js adapter
      -- dependencies = {
      --   -- Install the vscode-js-debug adapter
      --   {
      --     "microsoft/vscode-js-debug",
      --     -- After install, build it and rename the dist directory to out
      --     build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
      --     version = "1.*",
      --   },
      -- },
      config = function()
        print(vim.fn.stdpath("data"))
        require("dap-vscode-js").setup({
          -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
          debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter", -- 手动指定 mason 安装的 js adapter

          debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.

          adapters = {
            "chrome",
            "pwa-node",
            "pwa-chrome",
            "pwa-msedge",
            "node-terminal",
            "pwa-extensionHost",
          }, -- which adapters to register in nvim-dap

          -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging

          -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.

          -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
        })

        -- 参考：https://github.com/nikolovlazar/dotfiles/blob/main/.config/nvim/lua/plugins/dap.lua
        local js_based_languages = {
          "typescript",
          "javascript",
          "typescriptreact",
          "javascriptreact",
          "vue",
          "svelte",
        }
        for _, language in ipairs(js_based_languages) do
          require("dap").configurations[language] = {
            -- Debug single Node.js files
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = vim.fn.getcwd(),
              sourceMaps = true,
            },
            -- Debug node processes like express applications (make sure to add --inspect when you run the process)
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = vim.fn.getcwd(),
              sourceMaps = true,
            },
            -- Debug web applications (client side)
            {
              type = "pwa-chrome",
              request = "launch",
              name = "Launch & Debug Chrome",
              url = function()
                local co = coroutine.running()
                return coroutine.create(function()
                  vim.ui.input({
                    prompt = "Enter URL: ",
                    default = "http://localhost:3000",
                  }, function(url)
                    if url == nil or url == "" then
                      return
                    else
                      coroutine.resume(co, url)
                    end
                  end)
                end)
              end,
              webRoot = vim.fn.getcwd(),
              protocol = "inspector",
              sourceMaps = true,
              userDataDir = false,
            },
            -- Divider for the launch.json derived configs
            {
              name = "----- ↓ launch.json configs ↓ -----",
              type = "",
              request = "launch",
            },
          }
        end
      end,
    },
    -- 支持 json5 （注释等新特性）
    -- {
    --   "Joakker/lua-json5",
    --   build = "./install.sh",
    -- },
  },
}
