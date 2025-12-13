local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.empty(vim.fn.glob(lazypath)) == 1 then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.keymap.set("n", "<leader>L", "<cmd>Lazy update<CR>", { desc = "Lazy: Update plugins" })

require("lazy").setup("plugins", {
  defaults = {
    lazy = true,
    version = false,
  },
  install = {
    missing = true,
    colorscheme = { "catppuccin" },
  },
  headless = {
    task = true,
    colors = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin"
      },
    },
  },
  ui = {
    border = "rounded",
    backdrop = 60,
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    enabled = false,
  },
  debug = false,
})
