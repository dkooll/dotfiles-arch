return {
  "dkooll/tmuxer.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = { "WorkspaceOpen", "TmuxSessions" },
  config = function()
    require("tmuxer").setup({
      workspaces = {
        {
          name = "workspaces",
          path = "~/workspaces"
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
  keys = {
    {
      "<leader>tc",
      function()
        require("tmuxer").open_workspace_popup({
          name = "workspaces",
          path = "~/workspaces"
        })
      end,
      desc = "Tmuxer: Create Tmux Session"
    },
    {
      "<leader>ts",
      function()
        require("tmuxer").tmux_sessions()
      end,
      desc = "Tmuxer: Switch Tmux Session"
    },
  },
}
