return {
  "lervag/vimtex",
  lazy = false,
  config = function()
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_automatic = 1
  end,
  keys = {
    { "<localLear>l", "", desc = "+vimtex" },
  },
}
