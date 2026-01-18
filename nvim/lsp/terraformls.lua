local local_bin = vim.fn.expand("~/.local/bin/terraform-ls")
local cmd = vim.fn.executable(local_bin) == 1 and local_bin or "terraform-ls"

return {
  cmd = { cmd, "serve" },
  filetypes = { "terraform", "tf", "tfvars" },
  root_markers = { ".terraform", ".git" },
  single_file_support = true,
}

-- return {
--   cmd = { "terraform-ls", "serve" },
--   filetypes = { "terraform", "tf", "tfvars" },
--   root_markers = { ".terraform", ".git" },
--   single_file_support = true,
-- }
