return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":silent! TSUpdate",
    config = function(_, opts)
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if not ok then
        -- If the plugin isn't installed yet, install it synchronously and retry once
        local Lazy = require("lazy")
        Lazy.install({ plugins = { "nvim-treesitter" }, wait = true })
        ok, ts = pcall(require, "nvim-treesitter.configs")
        if not ok then
          return
        end
      end
      local function silent_setup()
        local orig_print = _G.print
        _G.print = function() end -- suppress verbose install output that causes hit-enter prompts
        local ok_setup, err = pcall(ts.setup, opts)
        _G.print = orig_print
        if not ok_setup then
          vim.notify("nvim-treesitter setup failed: " .. err, vim.log.levels.ERROR)
        end
      end

      silent_setup()

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
        "vimdoc",
        "yaml",
      },
      sync_install = true,
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local Lazy = require("lazy")

      -- Ensure plugin is present before configuring
      Lazy.install({ plugins = { "nvim-treesitter-textobjects" }, wait = true })
      pcall(Lazy.load, { plugins = { "nvim-treesitter-textobjects" }, wait = true })

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
          local ok_move, move = pcall(function()
            Lazy.install({ plugins = { "nvim-treesitter-textobjects" }, wait = true })
            pcall(Lazy.load, { plugins = { "nvim-treesitter-textobjects" }, wait = true })
            return require("nvim-treesitter-textobjects.move")
          end)
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
