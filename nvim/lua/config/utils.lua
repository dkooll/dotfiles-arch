local M = {}

M.telescope_git_or_file = function()
  local path = vim.fn.expand("%:p:h")
  local git_dir = vim.fn.finddir(".git", path .. ";")
  if #git_dir > 0 then
    require("telescope.builtin").git_files()
  else
    require("telescope.builtin").find_files()
  end
end

M.has_words_before = function()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

return M
