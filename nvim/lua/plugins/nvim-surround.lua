return {
  "kylechui/nvim-surround",
  version = "*",
  event = "InsertEnter",
  opts = {}                -- More efficient than empty config function
}

-- return {
--     "kylechui/nvim-surround",
--     version = "*", -- Use for stability; omit to use `main` branch for the latest features
--     event = "VeryLazy",
--     config = function()
--         require("nvim-surround").setup({
--             -- Configuration here, or leave empty to use defaults
--             -- https://github.com/kylechui/nvim-surround
--         })
--     end
-- }
