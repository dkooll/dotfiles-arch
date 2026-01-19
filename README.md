# dotfiles-arch

Sometimes you want to get your stuff set up fast. Use the bootstrap to clone, install, and link everything in one go:

`
curl -fsSL https://raw.githubusercontent.com/dkooll/dotfiles-arch/main/bootstrap.sh | bash
`

## Notes

### nvim-treesitter

Using the `master` branch (not `main`). The main branch is a complete rewrite for Neovim 0.11+ with a new API that's still unstable. Master provides the stable `nvim-treesitter.configs` API.

