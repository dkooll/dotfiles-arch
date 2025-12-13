local api = vim.api
local opt = vim.opt

local myGroup = api.nvim_create_augroup("MyAutocmds", { clear = true })

-- Helper for creating autocommands
local function create_autocmd(event, pattern, callback)
  api.nvim_create_autocmd(event, {
    pattern = pattern,
    callback = callback,
    group = myGroup,
  })
end

-- Don’t auto-comment new lines
opt.formatoptions:remove({ 'c', 'r', 'o' })

-- Remove trailing whitespace on save (skip binary buffers)
create_autocmd("BufWritePre", "*", function()
  if vim.bo.binary then
    return
  end
  vim.cmd([[silent! keepjumps keeppatterns %s/\s\+$//e]])
end)

-- Go to last location when opening a file
create_autocmd("BufReadPost", "*", function()
  local mark = api.nvim_buf_get_mark(0, '"')
  local lcount = api.nvim_buf_line_count(0)
  if mark[1] > 0 and mark[1] <= lcount then
    pcall(api.nvim_win_set_cursor, 0, mark)
  end
end)

-- Close man pages with 'q'
create_autocmd("FileType", "man", function()
  vim.keymap.set('n', 'q', ':quit<CR>', { buffer = true, silent = true })
end)

-- Clear cursor line after colorscheme load
create_autocmd("ColorScheme", "*", function()
  api.nvim_set_hl(0, 'CursorLine', { bg = 'NONE' })
end)

-- Configure fold column colors and transparent backgrounds
local function setup_colorscheme_overrides()
  api.nvim_set_hl(0, 'FoldColumn', { fg = '#9E8069', bg = 'NONE' })
  api.nvim_set_hl(0, 'Folded', { fg = '#9E8069', bg = 'NONE' })
  api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
  api.nvim_set_hl(0, 'FloatBorder', { fg = '#303030', bg = 'NONE' })
  api.nvim_set_hl(0, 'MasonNormal', { bg = 'NONE' })
  api.nvim_set_hl(0, 'MasonHeader', { bg = 'NONE' })
  api.nvim_set_hl(0, 'MasonHeaderSecondary', { bg = 'NONE' })
  api.nvim_set_hl(0, 'MasonBorder', { fg = '#303030', bg = 'NONE' })
  api.nvim_set_hl(0, 'LazyNormal', { bg = 'NONE' })
  api.nvim_set_hl(0, 'LazyBorder', { fg = '#303030', bg = 'NONE' })

  -- Telescope highlights
  api.nvim_set_hl(0, 'TelescopeSelection', { fg = "#9E8069" })
  api.nvim_set_hl(0, 'TelescopeSelectionCaret', { fg = "#9E8069" })
  api.nvim_set_hl(0, 'TelescopePromptPrefix', { fg = "#9E8069" })
  api.nvim_set_hl(0, 'TelescopeMatching', { fg = "#7DAEA3" })
  api.nvim_set_hl(0, 'TelescopeBoldType', { fg = "#9E8069", bold = true })
  api.nvim_set_hl(0, 'TelescopeNormal', { bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopeBorder', { fg = "#303030", bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopeTitle', { bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopePromptNormal', { bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopePromptBorder', { fg = "#303030", bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopePromptTitle', { bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopePromptCounter', { bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopeResultsNormal', { bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopeResultsBorder', { fg = "#303030", bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopeResultsTitle', { bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopePreviewNormal', { bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopePreviewBorder', { fg = "#303030", bg = "NONE" })
  api.nvim_set_hl(0, 'TelescopePreviewTitle', { bg = "NONE" })
end

create_autocmd("ColorScheme", "*", setup_colorscheme_overrides)
setup_colorscheme_overrides()
