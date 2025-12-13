return {
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview: Git Diff View File History" },
    },
    config = function()
      require("diffview").setup({})
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local icons = require("config.icons")
      require("gitsigns").setup {
        signs = {
          add = {
            text = icons.ui.BoldLineLeft,
          },
          change = {
            text = icons.ui.BoldLineLeft,
          },
          delete = {
            text = icons.ui.Triangle,
          },
          topdelete = {
            text = icons.ui.Triangle,
          },
          changedelete = {
            text = icons.ui.BoldLineLeft,
          },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
          yadm = { enable = false },
        },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        status_formatter = nil,
        update_debounce = 200,
        max_file_length = 40000,
        preview_config = {
          border = "rounded",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
      }
    end
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit kind=split_below<CR>", desc = "Neogit" },
    },
    opts = {
      disable_signs = false,
      disable_context_highlighting = true,
      commit_view = { kind = "tab", position = "tab" },
    },
  }
}
