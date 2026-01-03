return {
  "goolord/alpha-nvim",
  enabled = true,
  event = "VimEnter",
  priority = 50,
  lazy = true,
  keys = {
    { ";", "<cmd>Alpha<CR>", desc = "Dashboard: Alpha Menu" },
  },
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    local logo = [[
                                                     
              ████ ██████           █████      ██
             ███████████             █████ 
             █████████ ███████████████████ ███   ███████████
            █████████  ███    █████████████ █████ ██████████████
           █████████ ██████████ █████████ █████ █████ ████ █████
         ███████████ ███    ███ █████████ █████ █████ ████ █████
        ██████  █████████████████████ ████ █████ █████ ████ ██████

                              arch linux dev
     ]]
    dashboard.section.header.val = vim.split(logo, "\n")
    dashboard.section.buttons.val = vim.tbl_map(function(btn)
      local button = dashboard.button(btn[1], btn[2] .. " " .. btn[3], btn[4])
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
      return button
    end, {
      { "f", "", "Find file", ":Telescope fd <CR>" },
      { "n", "", "New file", ":ene <BAR> startinsert <CR>" },
      { "r", "", "Recent files", ":Telescope oldfiles <CR>" },
      { "g", "", "Find text", ":Telescope live_grep <CR>" },
      { "l", "󰒲", "Lazy", ":Lazy<CR>" },
      { "q", "", "Quit", ":qa<CR>" }
    })

    local function set_highlight(group, color)
      vim.api.nvim_set_hl(0, group, { fg = color })
    end

    set_highlight("AlphaHeader", 0xB87333)
    set_highlight("AlphaFooter", 0x808080)
    set_highlight("AlphaShortcut", 0x808080)
    set_highlight("AlphaButtons", 0x808080)

    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"
    dashboard.opts.layout[1].val = 8
    return dashboard
  end,
  config = function(_, dashboard)
    require("alpha").setup(dashboard.opts)
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local lazy_stats = require("lazy.stats").stats()
        local ms = (math.floor(lazy_stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = string.format(
          "Neovim loaded %d plugins in %.2fms",
          lazy_stats.count,
          ms
        )
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
