return {
  "nvim-flutter/flutter-tools.nvim",
  -- 改为按需加载（原 lazy=false 每次启动都加载，连带依赖 dressing 一起加载）。
  -- 打开 dart 文件即加载并注册全部 :Flutter* 命令；非 Flutter 场景启动更快。
  ft = "dart",
  cmd = { "FlutterRun", "FlutterDevices", "FlutterEmulators", "FlutterDevTools", "FlutterLspRestart" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for vim.ui.select
  },
  config = function()
    require("flutter-tools").setup({
      decorations = {
        statusline = {
          -- set to true to be able use the 'flutter_tools_decorations.app_version' in your statusline
          -- this will show the current version of the flutter app from the pubspec.yaml file
          app_version = true,
          -- set to true to be able use the 'flutter_tools_decorations.device' in your statusline
          -- this will show the currently running device if an application was started with a specific
          -- device
          device = true,
          -- set to true to be able use the 'flutter_tools_decorations.project_config' in your statusline
          -- this will show the currently selected project configuration
          project_config = true,
        },
      },
    })
  end,
}
