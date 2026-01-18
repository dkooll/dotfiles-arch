return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdateSync",
    config = function(_, opts)
      local ts = require("nvim-treesitter.configs")
      local install = require("nvim-treesitter.install")
      install.prefer_git = true -- avoid tarball layout issues that can cause mv failures

      ts.setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
          pcall(function()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end,
      })
    end,
    opts = {
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
      sync_install = true,
      auto_install = false, -- disable per-filetype auto installs to avoid nested autocmds
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ok, TS = pcall(require, "nvim-treesitter-textobjects")
      if ok and TS.setup then
        TS.setup({
          move = {
            enable = true,
            set_jumps = true,
          },
        })
      end

      -- Set up keymaps via autocmd to ensure plugin is loaded
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local buf = ev.buf
          local ok_move, move = pcall(require, "nvim-treesitter-textobjects.move")
          if not ok_move then
            return
          end

          local keymaps = {
            { "]m", "goto_next_start", "@function.outer" },
            { "]M", "goto_next_end", "@function.outer" },
            { "[m", "goto_previous_start", "@function.outer" },
            { "[M", "goto_previous_end", "@function.outer" },
            { "]]", "goto_next_start", "@class.outer" },
            { "][", "goto_next_end", "@class.outer" },
            { "[[", "goto_previous_start", "@class.outer" },
            { "[]", "goto_previous_end", "@class.outer" },
          }

          for _, map in ipairs(keymaps) do
            vim.keymap.set({ "n", "x", "o" }, map[1], function()
              move[map[2]](map[3], "textobjects")
            end, { buffer = buf, silent = true })
          end
        end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
}
