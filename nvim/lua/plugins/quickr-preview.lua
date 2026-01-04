return {
  {
    'ronakg/quickr-preview.vim',
    keys = {
      { '<leader>k', '<Plug>(quickr_preview)', desc = 'Quickr Preview' },
    },
    init = function()
      vim.g.quickr_preview_keymaps = 0
      vim.g.quickr_preview_position = 'below'
      vim.g.quickr_preview_options = 'norelativenumber nonumber nofoldenable'
      vim.g.quickr_preview_on_cursor = 0
      vim.g.quickr_preview_exit_on_enter = 1
      vim.g.quickr_preview_modifiable = 1
    end
  },
}
