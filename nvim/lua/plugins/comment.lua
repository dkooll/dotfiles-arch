return {
  'numToStr/Comment.nvim',
  keys = {
    { "<leader>c<leader>", mode = { "n", "v" }, desc = "Toggle comment" }
  },
  config = function()
    local api = require('Comment.api')
    require('Comment').setup({
      mappings = {
        basic = false,
        extra = false,
      }
    })

    vim.keymap.set('n', '<leader>c<leader>', api.toggle.linewise.current)
    vim.keymap.set('x', '<leader>c<leader>', function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
        api.toggle.linewise(vim.fn.visualmode())
    end)
  end
}
