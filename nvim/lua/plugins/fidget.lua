return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    progress = {
      display = {
        render_limit = 3,
        done_ttl = 3,
        priority = 50,
      },
    },
    notification = {
      window = {
        winblend = 0,
      },
    },
  },
}
