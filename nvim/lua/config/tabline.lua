-- Custom tabline
local function setup_highlights()
    vim.api.nvim_set_hl(0, 'TablineFilename', { fg = '#7DAEA3', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'TablineLsp', { fg = '#D3869B', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'TablineLazy', { fg = '#BD6F3E', bg = 'NONE', bold = true })
  vim.api.nvim_set_hl(0, 'TablineFill', { bg = 'NONE' })
end

local disabled_filetypes = { 'alpha', 'help', 'neo-tree', 'toggleterm' }

local function is_disabled()
  return vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
end

local function get_filename()
  local name = vim.fn.expand('%:~:.')
  if name == '' then return '' end
  local modified = vim.bo.modified and '  ' or ''
  return name .. modified .. ' '
end

local function get_lsp_servers()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return '' end
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  return ' ' .. table.concat(names, ', ') .. ' '
end

local function get_lazy_updates()
  local current_time = vim.fn.reltimefloat(vim.fn.reltime())
  if not vim.g.lazy_updates_time or (current_time - vim.g.lazy_updates_time) > 5.0 then
    local ok, lazy = pcall(require, 'lazy.status')
    if ok then
      vim.g.lazy_updates_cache = lazy.has_updates() and lazy.updates() or ''
    else
      vim.g.lazy_updates_cache = ''
    end
    vim.g.lazy_updates_time = current_time
  end
  return vim.g.lazy_updates_cache or ''
end

function _G.custom_tabline()
  if is_disabled() or vim.fn.buflisted(vim.fn.bufnr()) ~= 1 then
    return ''
  end

  local filename = get_filename()
  local lsp = get_lsp_servers()
  local lazy = get_lazy_updates()

  return table.concat({
    '%#TablineFilename#', filename,
    '%#TablineLsp#', lsp,
    '%#TablineLazy#', lazy,
    '%#TablineFill#',
  })
end

setup_highlights()
vim.o.tabline = '%!v:lua.custom_tabline()'
vim.o.showtabline = 2

vim.o.laststatus = 0

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = setup_highlights,
})
