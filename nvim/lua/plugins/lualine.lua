return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons",  event = "VeryLazy" },
    { "meuter/lualine-so-fancy.nvim", event = "VeryLazy" },
  },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "catppuccin",
      globalstatus = true,
      icons_enabled = true,
      component_separators = "",
      section_separators = "",
      disabled_filetypes = {
        statusline = { "help", "neo-tree", "toggleterm", "alpha" },
        tabline = { "alpha" },
      },
      refresh = {
        statusline = 5000,
        tabline = 5000,
        winbar = 5000,
      }
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {
      lualine_a = {
        {
          "fancy_branch",
          cond = function() return vim.fn.buflisted(vim.fn.bufnr()) == 1 end,
          color = { fg = "#7DAEA3", bg = "NONE" }
        },
        {
          "filename",
          cond = function() return vim.fn.buflisted(vim.fn.bufnr()) == 1 end,
          color = { fg = "#D3869B", bg = "NONE" },
          path = 1,
          symbols = { modified = "  " }
        },
        {
          "fancy_lsp_servers",
          cond = function() return vim.fn.buflisted(vim.fn.bufnr()) == 1 end,
          color = { fg = "#D3869B", bg = "NONE" }
        },
        {
          function()
            -- Cache lazy updates to avoid frequent require() calls
            local current_time = vim.fn.reltimefloat(vim.fn.reltime())
            if not vim.g.lazy_updates_cache or not vim.g.lazy_updates_time or (current_time - vim.g.lazy_updates_time) > 5.0 then
              local lazy = require("lazy.status")
              vim.g.lazy_updates_cache = lazy.has_updates() and lazy.updates() or ""
              vim.g.lazy_updates_time = current_time
            end
            return vim.g.lazy_updates_cache
          end,
          cond = function()
            if vim.fn.buflisted(vim.fn.bufnr()) ~= 1 then
              return false
            end
            return vim.g.lazy_updates_cache and vim.g.lazy_updates_cache ~= ""
          end,
          color = { fg = "#BD6F3E", bg = "NONE", gui = "bold" }
        },
      },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    extensions = { "neo-tree" },
  },
}
