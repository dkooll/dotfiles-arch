-- Pin to 0.38.2 due to schema bug in 0.38.3
local local_bin = vim.fn.expand("~/.local/bin/terraform-ls")

return {
  cmd = { local_bin, "serve" },
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
