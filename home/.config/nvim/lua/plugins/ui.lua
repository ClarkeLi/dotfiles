return {
  -- 顶部标签页：圆润一点
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        separator_style = "thin",
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
      },
    },
  },
  -- 状态栏：不要花哨分隔符
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      })
    end,
  },
  -- 启动页
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = true }, -- 平滑滚动
      indent = { animate = { enabled = false } },
      dashboard = { preset = { header = [[
 ███╗   ██╗██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██║   ██║██║████╗ ████║
 ██╔██╗ ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]] } },
    },
  },
}
