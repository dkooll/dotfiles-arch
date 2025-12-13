return {
  "dkooll/bouncer.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = true,
  cmd = { "BounceModuleToLocal", "BounceModuleToRegistry", "BounceModulesToRegistry" },
  keys = {
    { "<leader>bl", ":BounceModuleToLocal<CR>",     desc = "Bouncer: Bounce Current Module to Local format" },
    { "<leader>br", ":BounceModuleToRegistry<CR>",  desc = "Bouncer: Bounce Current Module to Registry format" },
    { "<leader>ba", ":BounceModulesToRegistry<CR>", desc = "Bouncer: Bounce All Modules to Registry format" },
  },
  config = function()
    require("bouncer").setup({
      namespace = "cloudnationhq"
    })
  end,
}
