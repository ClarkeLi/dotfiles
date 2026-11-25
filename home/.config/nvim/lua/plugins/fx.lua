-- 视觉特效:光标拖尾、窗口动画、玻璃浮窗、命令面板、代码美化
return {
  -- 光标拖尾(终端里也能用)
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      smear_between_buffers = true,
      smear_insert_mode = true,
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
    },
  },

  -- 窗口开合/缩放动画(滚动交给 snacks,避免冲突)
  {
    "nvim-mini/mini.animate",
    event = "VeryLazy",
    opts = function()
      local animate = require("mini.animate")
      return {
        cursor = { enable = false }, -- 光标动画由 smear-cursor 负责
        scroll = { enable = false },
        resize = { timing = animate.gen_timing.linear({ duration = 80, unit = "total" }) },
        open = { timing = animate.gen_timing.linear({ duration = 100, unit = "total" }) },
        close = { timing = animate.gen_timing.linear({ duration = 100, unit = "total" }) },
      }
    end,
  },

  -- 命令行/消息变成居中浮窗(像 VSCode 命令面板)
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- 玻璃感:浮窗与补全菜单半透明
  {
    "LazyVim/LazyVim",
    init = function()
      vim.opt.winblend = 12
      vim.opt.pumblend = 12
    end,
  },

  -- 彩虹括号
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "LazyFile",
    main = "rainbow-delimiters.setup",
  },

  -- 行内诊断(替代右侧虚拟文本,更清爽)
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = { preset = "modern", options = { show_source = true } },
    init = function()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  -- 现代折行:zR 全展开 / zM 全折叠
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "LazyFile",
    init = function()
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    opts = {
      provider_selector = function() return { "lsp", "indent" } end,
    },
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
    },
  },
}
