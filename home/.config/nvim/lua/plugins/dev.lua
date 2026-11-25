-- 开发功能:Claude / Git 全家桶 / 调试测试 / 会话终端
return {
  -- Claude Code 集成:在 nvim 内直接和 Claude 对话,能看到你选中的代码和 diff
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    opts = { terminal = { split_side = "right", split_width_percentage = 0.38 } },
    keys = {
      { "<leader>a", nil, desc = "AI / Claude" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file", ft = { "neo-tree", "NvimTree", "oil", "snacks_picker_list" } },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },

  -- Git:分屏 diff、文件历史
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview (all changes)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    opts = { enhanced_diff_hl = true },
  },
  -- 行内 blame
  {
    "lewis6991/gitsigns.nvim",
    opts = { current_line_blame = true, current_line_blame_opts = { delay = 400 } },
  },
  -- 在 nvim 里审 PR / issue (需要 gh 已登录)
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim", "nvim-tree/nvim-web-devicons" },
    opts = { picker = "snacks", enable_builtin = true },
    keys = {
      { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "PR list" },
      { "<leader>gi", "<cmd>Octo issue list<cr>", desc = "Issue list" },
    },
  },

  -- 终端:Ctrl+\ 呼出浮动终端(snacks 自带)
  {
    "folke/snacks.nvim",
    keys = {
      { "<C-\\>", function() Snacks.terminal(nil, { win = { style = "float" } }) end, mode = { "n", "t" }, desc = "Float terminal" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    },
  },
}
