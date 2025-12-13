return {
  "catppuccin/nvim",
  lazy = false,
  priority = 1000,
  name = "catppuccin",
  opts = {
    color_overrides = {
      mocha = {
        rosewater = "#EA6962",
        flamingo = "#EA6962",
        pink = "#D3869B",
        mauve = "#D3869B",
        red = "#EA6962",
        maroon = "#EA6962",
        peach = "#BD6F3E",
        yellow = "#D8A657",
        green = "#A9B665",
        teal = "#89B482",
        sky = "#89B482",
        sapphire = "#89B482",
        blue = "#7DAEA3",
        lavender = "#7DAEA3",
        text = "#D4BE98",
        subtext1 = "#BDAE8B",
        subtext0 = "#A69372",
        overlay2 = "#8C7A58",
        overlay1 = "#735F3F",
        overlay0 = "#958272",
        surface2 = "#4B4F51",
        surface1 = "#2A2D2E",
        surface0 = "#232728",
        base = "#1D2021",
        mantle = "#191C1D",
        crust = "#151819",
      },
    },
    styles = {},
    transparent_background = true,
    show_end_of_buffer = false,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      telescope = {
        enabled = true,
      },
      lsp_trouble = false,
    },
    custom_highlights = function(colors)
      return {
        CursorLineNr = { fg = colors.mauve },
        IndentBlanklineChar = { fg = colors.surface0 },
        IndentBlanklineContextChar = { fg = colors.surface2 },
        GitSignsChange = { fg = colors.peach },
        NvimTreeIndentMarker = { link = "IndentBlanklineChar" },
        NvimTreeExecFile = { fg = colors.text },
        Visual = { fg = "#9E8069" },
        FloatBorder = { fg = "#303030" },
        Comment = { fg = "#9E8069" },
        -- Terraform LSP semantic token highlights
        ["@lsp.type.enumMember.terraform"] = { fg = colors.peach },
        ["@type.builtin.terraform"] = { fg = colors.yellow },
      }
    end,
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd([[
      set guicursor=n-v-c:block-CursorInsert,i-ci-ve:hor20-CursorInsert,r-cr:hor20-CursorInsert,o:hor50-CursorInsert
      highlight CursorInsert guifg=NONE guibg=#9E8069
      highlight Cursor guifg=NONE guibg=#9E8069
      colorscheme catppuccin
    ]])
  end,
}
