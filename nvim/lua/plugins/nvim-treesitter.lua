return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  -- event = "VeryLazy",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
  },
  opts = {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    autotag = { enable = true },
    ensure_installed = {
      "bash",
      "dockerfile",
      "go",
      "gomod",
      "gosum",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "regex",
      "rust",
      "terraform",
      "hcl",
      "vim",
      "yaml",
    },
    sync_install = false,
    auto_install = true,
    ignore_install = {},
    modules = {},
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<leader>vv",
        node_incremental = "<leader>vv",
        scope_incremental = false,
        node_decremental = "<BS>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
