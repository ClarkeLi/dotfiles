-- 编辑体验:Tab 接受补全、AI 行内补全
return {
  -- 补全:Tab 接受/跳到下一个占位符,Shift+Tab 反向(和 VSCode 一样)
  {
    "saghen/blink.cmp",
    opts = {
      keymap = { preset = "super-tab" },
    },
  },

  -- AI 行内补全(灰色预测文字),需要 GitHub Copilot 订阅;首次用 :Copilot auth 登录
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-l>", -- 接受整段建议
          accept_word = "<C-Right>", -- 只接受一个词
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = { markdown = true, help = false },
    },
  },
}
