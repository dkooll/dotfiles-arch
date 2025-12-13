return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json" },
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
        extraArgs = { "--all-features" }
      },
      cargo = {
        loadOutDirsFromCheck = true,
        allFeatures = true,
      },
      procMacro = { enable = true },
      lens = { enable = true },
      diagnostics = {
        disabled = { "unresolved-proc-macro" },
        enableExperimental = false,
      },
      completion = {
        privateEditable = { enable = false },
        fullFunctionSignatures = { enable = false },
      },
    },
  }
}
