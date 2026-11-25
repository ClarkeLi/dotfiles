-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

-- VSCode 肌肉记忆
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<C-p>", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<F2>", function() return ":IncRename " .. vim.fn.expand("<cword>") end, { expr = true, desc = "Rename symbol" })
map("n", "<F12>", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<S-F12>", vim.lsp.buf.references, { desc = "References" })
-- Ctrl+点击跳转到定义(和 VSCode 一样;先点一下移动光标再跳转)
map("n", "<C-LeftMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Go to definition" })
-- 悬停文档:鼠标点到符号上后按 F1 查看(等同 K)
map("n", "<F1>", vim.lsp.buf.hover, { desc = "Hover docs" })

-- 文件树 / 终端(VSCode: Ctrl+B 侧边栏)
map("n", "<C-b>", function() Snacks.explorer() end, { desc = "File explorer" })

-- 调试(VSCode 同款功能键)
map("n", "<F5>", function() require("dap").continue() end, { desc = "Debug: continue / start" })
map("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "Debug: toggle breakpoint" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "Debug: step over" })
map("n", "<F11>", function() require("dap").step_into() end, { desc = "Debug: step into" })
map("n", "<S-F11>", function() require("dap").step_out() end, { desc = "Debug: step out" })

-- 折行文本里按视觉行移动
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- 粘贴不覆盖寄存器
map("x", "p", [["_dP]], { desc = "Paste without yanking" })
