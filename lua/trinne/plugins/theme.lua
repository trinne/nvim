-- Colorschemes for the themes in lua/trinne/theme.lua. All are lazy: lazy.nvim loads the
-- right one (and runs its setup with `opts`) when theme.lua calls :colorscheme.
-- Backgrounds are transparent so the terminal's opacity shows through.
return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "storm",
      transparent = true,
      styles = {
        sidebars = "transparent",
      },
    },
  },
  {
    "gbprod/nord.nvim",
    lazy = true,
    opts = {
      transparent = true,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",
      transparent_background = true,
    },
  },
}
