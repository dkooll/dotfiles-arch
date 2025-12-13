return {
  "PHSix/faster.nvim",
  keys = {
    { "<Up>",   mode = { "n", "v" } },
    { "<Down>", mode = { "n", "v" } },
  },
  config = function()
    vim.keymap.set('n', '<Down>', '<Plug>(faster_move_j)', { silent = true })
    vim.keymap.set('n', '<Up>', '<Plug>(faster_move_k)', { silent = true })
    vim.keymap.set('v', '<Down>', '<Plug>(faster_vmove_j)', { silent = true })
    vim.keymap.set('v', '<Up>', '<Plug>(faster_vmove_k)', { silent = true })
  end
}
