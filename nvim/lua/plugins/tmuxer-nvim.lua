return {
  "dkooll/tmuxer.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd          = { "TmuxCreateSession", "TmuxSwitchSession", "TmuxToggleArchive" },
  config       = function()
    require("tmuxer").setup({
      nvim_alias = "NVIM_APPNAME=nvim-dev nvim",
      workspaces = {
        {
          name = "workspaces",
          path = "~/Documents/workspaces"
        }
      },
      max_depth = 2,
      theme = "ivy",
      previewer = false,
      border = true,
      parent_highlight = {
        fg = "#9E8069",
        bold = true,
      },
      layout_config = {
        width = 0.5,
        height = 0.31,
      }
    })
  end,
  keys         = {
    { "<leader>tc", "<cmd>TmuxCreateSession<cr>",  desc = "Tmuxer: Create Session" },
    { "<leader>ts", "<cmd>TmuxSwitchSession<cr>",  desc = "Tmuxer: Switch Session" },
    { "<leader>ta", "<cmd>TmuxToggleArchive<cr>",  desc = "Tmuxer: Toggle Archive" },
    { "<leader>th", "<cmd>checkhealth tmuxer<cr>", desc = "Tmuxer: Health Check" },
  },
}
