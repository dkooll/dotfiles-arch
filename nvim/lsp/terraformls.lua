return {
  cmd = { "terraform-ls", "serve" },
  filetypes = { "terraform", "tf", "tfvars" },
  root_markers = { ".terraform", ".git" },
  single_file_support = true,
}
