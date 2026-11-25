-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- 中文友好：CJK 不当作拼写错误
opt.spelllang = { "en", "cjk" }
opt.wrap = true
opt.linebreak = true -- 在单词边界折行
opt.breakindent = true -- 折行后保持缩进

-- 外观（VSCode 风格）
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.pumheight = 12
opt.laststatus = 3 -- 全局唯一状态栏
opt.winborder = "rounded" -- 0.11: 所有浮窗统一圆角
opt.fillchars = { eob = " ", fold = " " }

-- 行为
opt.mouse = "a"
opt.undofile = true
opt.confirm = true -- 退出时询问而不是报错
opt.splitkeep = "screen"
opt.smoothscroll = true
opt.updatetime = 200
