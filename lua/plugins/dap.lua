-- 参考：https://github.com/nikolovlazar/dotfiles/blob/main/.config/nvim/lua/plugins/dap.lua
local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
  "vue",
  "svelte",
}

return {
  "mfussenegger/nvim-dap",
  lazy = true,
  keys = {
    {
      "<leader>dc",
      function()
        if vim.fn.filereadable(".vscode/launch.json") then
          -- 参考：https://github.com/mfussenegger/nvim-dap/blob/master/doc/dap.txt
          local dap_vscode = require("dap.ext.vscode")
          dap_vscode.load_launchjs(nil, {
            -- launch.json 中 type 对应的文件类型
            -- 需要指定，否则无法识别 launch.json 文件
            ["chrome"] = js_based_languages,
            ["msedge"] = js_based_languages,
            ["node"] = js_based_languages,
            ["node-terminal"] = js_based_languages,
            ["pwa-chrome"] = js_based_languages,
            ["pwa-msedge"] = js_based_languages,
            ["pwa-node"] = js_based_languages,
          })
        end
        require("dap").continue()
      end,
      desc = "Run with Args",
    },
  },
  dependencies = {
    -- mason.nvim integration
    -- 如果 vscode-js-debug 安装构建会报错，可以使用 mason 安装 js adapter（但是只能安装 1.76.1 版本）
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason.nvim",
      -- NOTE: 需要手动调用 :DapInstall 安装，并通过 :Mason 唤起 mason 面板查看安装进度
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
          -- 若安装失败，指定 npm 代理，参考：https://github.com/npm/npm/issues/7945#issuecomment-140382071
          "js@v1.76.1",
        },
      },
    },

    -- for Javascript / Typescript
    {
      "mxsdev/nvim-dap-vscode-js",
      -- NOTE: 如果 vscode-js-debug 安装不了，可以使用 mason 安装 js adapter
      dependencies = {
        -- Install the vscode-js-debug adapter
        {
          "microsoft/vscode-js-debug",
          -- After install, build it and rename the dist directory to out
          build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
          pin = true,
          -- version = "1.*",
        },
        -- 支持 json5 （注释等新特性）
        -- {
        --   "Joakker/lua-json5",
        --   -- 构建错误，待解决
        --   build = "./install.sh",
        -- },
      },
      config = function()
        -- require("dap.ext.vscode").json_decode = require("json5").parse

        require("dap-vscode-js").setup({
          -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"

          -- debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter", -- 手动指定 mason 安装的 js adapter
          -- NOTE: 使用 mason 安装的最新版 js adapter 会有问题，所以直接使用 lazy 安装
          debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug", -- 手动指定 lazy 安装的 js adapter

          -- debugger_cmd 优先级更高，这里不设置，而是使用 debugger_path
          -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.

          adapters = {
            "chrome",
            "pwa-node",
            "pwa-chrome",
            "pwa-msedge",
            "node-terminal",
            "pwa-extensionHost",
            "node",
            "chrome",
          }, -- which adapters to register in nvim-dap

          -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging

          -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.

          -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
        })

        --      ╭────────────────────────────────────────────────────────────────╮
        --      │                           配置参考：                           │
        --      │https://github.com/ecosse3/nvim/blob/master/lua/plugins/dap.lua │
        --      ╰────────────────────────────────────────────────────────────────╯
        for _, language in ipairs(js_based_languages) do
          require("dap").configurations[language] = {
            --          ╭─────────────────────────────────────────────────────────╮
            --          │                       唤起浏览器                        │
            --          ╰─────────────────────────────────────────────────────────╯
            -- 首先需要开启本地服务，然后输入运行服务的端口号，唤起一个浏览器
            {
              type = "pwa-chrome",
              request = "launch",
              name = "Launch Chrome",
              url = function()
                local co = coroutine.running()
                return coroutine.create(function()
                  vim.ui.input({
                    prompt = 'Enter URL: ',
                    default = 'http://localhost:3000'
                  }, function(url)
                    if url == nil or url == '' then
                      return
                    else
                      coroutine.resume(co, url)
                    end
                  end)
                end)
              end,
              webRoot = vim.fn.getcwd(),
              protocol = 'inspector',
              sourceMaps = true,
              userDataDir = false,
              resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
              },
              runtimeArgs = {
                -- 自动打开调试面板
                "--auto-open-devtools-for-tabs"
              }
            },
            --          ╭─────────────────────────────────────────────────────────╮
            --          │                       关联浏览器                        │
            --          ╰─────────────────────────────────────────────────────────╯
            -- 首先需要手动运行 `chrome：<chrome 运行文件路径> --remote-debugging-port=9222 --user-data-dir=<用户创建的目录>`
            -- 通过 localhost:9222/json 可以查看所有 ws 服务的地址
            {
              type = "pwa-chrome",
              request = "attach",
              name = "Attach Chrome",
              program = "${file}",
              cwd = vim.fn.getcwd(),
              sourceMaps = true,
              protocol = 'inspector',
              port = function()
                return vim.fn.input("Select port: ", 9222)
              end,
              webRoot = "${workspaceFolder}",
            },
            --          ╭─────────────────────────────────────────────────────────╮
            --          │                     调试 node 文件                      │
            --          ╰─────────────────────────────────────────────────────────╯
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Node (use node)",
              cwd = vim.fn.getcwd(),
              runtimeArgs = { "${file}", },
              runtimeExecutable = "node",
              rootPath = "${workspaceFolder}",
              sourceMaps = true,
              console = "integratedTerminal",
              skipFiles = { "<node_internals>/**", },
            },
            --          ╭─────────────────────────────────────────────────────────╮
            --          │                     调试 node 文件                      │
            --          ╰─────────────────────────────────────────────────────────╯
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Node (use ts-node)",
              cwd = vim.fn.getcwd(),
              runtimeArgs = { "${file}", },
              runtimeExecutable = "ts-node",
              rootPath = "${workspaceFolder}",
              sourceMaps = true,
              console = "integratedTerminal",
              skipFiles = { "<node_internals>/**", },
            },
            --          ╭─────────────────────────────────────────────────────────╮
            --          │                     调试 node 文件                      │
            --          ╰─────────────────────────────────────────────────────────╯
            -- 通过运行 `node --inspect-brk ${file}` 启动调试模式并在首行断住
            -- 默认端口为 9229
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Node (by Port)",
              cwd = vim.fn.getcwd(),
              runtimeArgs = { "--inspect-brk", "${file}" },
              console = "integratedTerminal",
              runtimeExecutable = "node",
              attachSimplePort = 9229,
            },
            --          ╭─────────────────────────────────────────────────────────╮
            --          │                     调试 node 文件                      │
            --          ╰─────────────────────────────────────────────────────────╯
            -- 手动运行 `node --inspect-brk ${file}` 启动调试模式，并获取到监听的端口号
            -- 通过端口号连接到调试进程中
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach Node (by Port)",
              program = "${file}",
              cwd = vim.fn.getcwd(),
              sourceMaps = true,
              protocol = 'inspector',
              port = function()
                return vim.fn.input("Select port: ", 9229)
              end,
              webRoot = "${workspaceFolder}",
              console = "integratedTerminal",
              -- 跳过的文件将不会在调用栈中展示
              skipFiles = {
                -- 精简调用栈（跳过 node 内部的文件）
                "<node_internals>/**"
              },
              -- 失败后 1s 重试⼀次，最多 3 次
              restart = {
                delay = 1000,
                maxAttempts = 3
              }
            },
            --          ╭─────────────────────────────────────────────────────────╮
            --          │                     调试 node 文件                      │
            --          ╰─────────────────────────────────────────────────────────╯
            -- 手动运行 `node --inspect-brk ${file}` 启动调试模式，并获取到监听的端口号
            -- 通过 `lsof -i:${port}` 获取对应端口号的进程 id
            -- 通过进程 id 连接到调试进程中
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach Node (by ProcessId)",
              program = "${file}",
              cwd = vim.fn.getcwd(),
              sourceMaps = true,
              protocol = 'inspector',
              webRoot = "${workspaceFolder}",
              console = "integratedTerminal",
              skipFiles = { "<node_internals>/**" },
              -- 失败后 1s 重试⼀次，最多 3 次
              restart = {
                delay = 1000,
                maxAttempts = 3
              },
              processId = require('dap.utils').pick_process
            },
            --          ╭─────────────────────────────────────────────────────────╮
            --          │                      调试 npm 脚本                      │
            --          ╰─────────────────────────────────────────────────────────╯
            -- 本质是运行 `npm run xxx` 脚本命令，需要在脚本文件内打上断点
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Node (npm run scripts)",
              cwd = vim.fn.getcwd(),
              args = { "${file}" },
              sourceMaps = true,
              protocol = "inspector",
              runtimeExecutable = "npm",
              -- 打印到 dap-terminal 中
              console = "integratedTerminal",
              -- npm run start
              runtimeArgs = {
                "run-script", function()
                return vim.fn.input("npm run ", 'start')
              end
              },
              resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
              }
            },
            -- TODO:
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Node (node xxx)",
              cwd = vim.fn.getcwd(),
              runtimeArgs = { "${workspaceFolder}/node_modules/.bin/react-scripts" },
              runtimeExecutable = "node",
              args = { "start" },
              rootPath = "${workspaceFolder}",
              sourceMaps = true,
              console = "integratedTerminal",
              internalConsoleOptions = "neverOpen",
              skipFiles = { "<node_internals>/**", "node_modules/**" },
            },
            -- Divider for the launch.json derived configs
            {
              name = "----- ↓ launch.json configs ↓ -----",
              type = "",
              request = "launch",
            },
          }
        end

        -- 查看错误日志：~/.cache/nvim/dap.log
        require("dap").set_log_level("TRACE")
      end,
    },
  },
}
