-- Monokai Pro 是整套 UI 的底色，不要换。
-- filter 可选: pro(默认) | classic(最接近原版 Monokai) | octagon | machine | ristretto | spectrum
return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      filter = "pro",
      transparent_background = false,
      terminal_colors = true,
      inc_search = "background",
      -- 补齐旧版 monokai-pro 没覆盖到的新插件高亮 (snacks / blink.cmp / edgy)
      override = function(c)
        local hl = vim.api.nvim_set_hl
        local d = c.base.dimmed2 or c.base.dimmed3
        hl(0, "SnacksIndent", { fg = c.base.dimmed5 or d })
        hl(0, "SnacksIndentScope", { fg = c.base.dimmed2 or d })
        hl(0, "SnacksPickerBorder", { link = "FloatBorder" })
        hl(0, "SnacksPickerTitle", { link = "FloatTitle" })
        hl(0, "BlinkCmpMenuBorder", { link = "FloatBorder" })
        hl(0, "BlinkCmpDocBorder", { link = "FloatBorder" })
        hl(0, "EdgyNormal", { link = "NormalFloat" })
        hl(0, "TreesitterContext", { link = "CursorLine" })
        hl(0, "TreesitterContextBottom", { underline = true, sp = c.base.dimmed4 or d })
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "monokai-pro" },
  },
}
