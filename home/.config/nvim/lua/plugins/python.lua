-- Python:自动找 .venv、保存时用 ruff 格式化、调试器 debugpy
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          -- 启动前:从项目根目录开始往上找 .venv,找到就把它的 python 交给 pyright
          before_init = function(_, config)
            local root = config.root_dir or vim.fn.getcwd()
            local venv = vim.fs.find(".venv", { path = root, upward = true, type = "directory" })[1]
            if venv then
              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = venv .. "/bin/python"
            end
          end,
          settings = {
            python = {
              analysis = {
                -- standard 已经够严:strict 在 SQLModel 项目里会冒出上百条误报
                typeCheckingMode = "standard",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
      },
    },
  },

  -- 保存时自动:修复可修复的问题 → 整理 import → 格式化(和项目提交前的 ruff 检查一致)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
      },
    },
  },

  -- 调试器:自动安装 debugpy
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "debugpy" } },
  },
}
