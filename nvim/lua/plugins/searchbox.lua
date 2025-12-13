return {
  "VonHeikemen/searchbox.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  lazy = true,
  keys = {
    { "<leader>si", ":SearchBoxIncSearch<CR>", desc = "Searchbox: Incremental Search" },
    { "<leader>sa", ":SearchBoxMatchAll<CR>",  desc = "Searchbox: Match All" },
    { "<leader>ss", ":SearchBoxSimple<CR>",    desc = "Searchbox: Simple Search" },
    { "<leader>sr", ":SearchBoxReplace<CR>",   desc = "Searchbox: Replace" },
  },
}
