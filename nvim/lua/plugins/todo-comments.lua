return {
  "folke/todo-comments.nvim",
  enabled = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    { "<leader>tt", "<cmd>TodoTelescope previewer=false<cr>",                                    desc = "Todo: Open Todo List" },
    { "<leader>tf", "<cmd>TodoTelescope keywords=FIX,FIXME,BUG,FIXIT,ISSUE previewer=false<cr>", desc = "Todo: Open Fix List" },
    { "<leader>td", "<cmd>TodoTelescope keywords=TODO previewer=false<cr>",                      desc = "Todo: Open Todo List" },
    { "<leader>tn", "<cmd>TodoTelescope keywords=NOTE,INFO previewer=false<cr>",                 desc = "Todo: Open Note List" },
    { "<leader>th", "<cmd>TodoTelescope keywords=HACK previewer=false<cr>",                      desc = "Todo: Open hack List" },
    { "<leader>tw", "<cmd>TodoTelescope keywords=WARN,WARNING,XXX previewer=false<cr>",          desc = "Todo: Open warn List" },
    { "<leader>tq", "<cmd>TodoQuickFix<cr>",                                                     desc = "Todo: Add to Quickfix" },
    { "<leader>tl", "<cmd>TodoLocList<cr>",                                                      desc = "Todo: Add to Location List" },
    { "<leader>tT", "<cmd>TodoTrouble<cr>",                                                      desc = "Todo: Open Trouble" },
  },
  config = function()
    require("todo-comments").setup({
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      gui_style = {
        fg = "NONE",
        bg = "BOLD",
      },
      merge_keywords = true,
      highlight = {
        multiline = true,
        multiline_pattern = "^.",
        multiline_context = 10,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
        exclude = {},
      },
      -- list of highlight groups or use the hex color if hl not found as a fallback
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
      },
    })
  end
}
