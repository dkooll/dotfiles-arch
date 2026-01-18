return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":silent! TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
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
        "vimdoc",
        "yaml",
      },
      sync_install = false,
      auto_install = true, -- install missing parsers on first use
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
      local ok_cfg, cfg = pcall(require, "nvim-treesitter.configs")
      if not ok_cfg then
        return
      end

      -- Prefer git checkout to avoid tarball path issues (e.g., gomod main branch)
      local ok_install, install = pcall(require, "nvim-treesitter.install")
      if ok_install then
        install.prefer_git = true
      end

      -- suppress installer output to avoid hit-enter prompts
      local orig_print = _G.print
      _G.print = function() end
      local ok_setup, err = pcall(cfg.setup, opts)
      _G.print = orig_print
      if not ok_setup then
        vim.notify("nvim-treesitter setup failed: " .. err, vim.log.levels.ERROR)
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ok = pcall(require, "nvim-treesitter.configs")
      if not ok then
        return
      end
      -- modules configured via main treesitter opts
    end,
  },
}
