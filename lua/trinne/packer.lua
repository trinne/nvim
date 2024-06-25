-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")

  -- General helpers that many plugins use
  use("nvim-lua/plenary.nvim")

  -- Finding files
  use({
    "nvim-telescope/telescope.nvim",
    tag = "0.1.2",
    -- or                            , branch = '0.1.x',
    requires = { { "nvim-lua/plenary.nvim" } },
  })
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use({ "nvim-telescope/telescope-ui-select.nvim" })

  -- Harpoon
  use("ThePrimeagen/harpoon")

  -- Filetree
  use("nvim-tree/nvim-tree.lua")

  -- History
  use("mbbill/undotree")

  -- GIT
  use("tpope/vim-fugitive")
  use("lewis6991/gitsigns.nvim")

  -- Syntax highlight
  use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })

  -- Language server
  use({
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    requires = {
      -- LSP Support
      { "neovim/nvim-lspconfig" }, -- Required
      { "williamboman/mason.nvim" }, -- Optional
      { "williamboman/mason-lspconfig.nvim" }, -- Optional

      -- Autocompletion
      { "hrsh7th/nvim-cmp" }, -- Required
      { "hrsh7th/cmp-nvim-lsp" }, -- Required
      { "L3MON4D3/LuaSnip" }, -- Required
      { "hrsh7th/cmp-vsnip" },
      { "hrsh7th/vim-vsnip" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "onsails/lspkind.nvim" }, -- Optional symbols in completions
    },
  })
  -- Sonarlint
  use("https://gitlab.com/schrieveslaach/sonarlint.nvim.git")

  -- Github CoPilot
  use("github/copilot.vim")

  -- Code structure
  use("simrat39/symbols-outline.nvim")

  -- Debugging
  use("mfussenegger/nvim-dap")
  use({
    "rcarriga/nvim-dap-ui",
    requires = {
      "mfussenegger/nvim-dap",
      "folke/neodev.nvim",
    },
  })
  use({
    "nvim-telescope/telescope-dap.nvim",
    requires = {
      { "mfussenegger/nvim-dap" },
      { "nvim-telescope/telescope.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
  })

  -- Java language server tools
  use("mfussenegger/nvim-jdtls")

  -- SQL
  use("tpope/vim-dadbod")
  use("kristijanhusak/vim-dadbod-ui")
  use("kristijanhusak/vim-dadbod-completion")

  -- Errors and warnings
  use({
    "folke/trouble.nvim",
    requires = { { "nvim-tree/nvim-web-devicons" } },
  })
  -- Projectwide diagnostics
  use({ "artemave/workspace-diagnostics.nvim" })

  -- Test
  use("vim-test/vim-test")
  use({
    "nvim-neotest/neotest",
    requires = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-vim-test",
      "andy-bell101/neotest-java",
      "marilari88/neotest-vitest",
      "vim-test/vim-test",
    },
  })

  -- Theme
  use("folke/tokyonight.nvim")

  -- Bottom toolbar
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons", opt = true },
  })

  -- Todo comments
  use({
    "folke/todo-comments.nvim",
    requires = { "nvim-lua/plenary.nvim" },
  })

  -- Code formatting
  use("stevearc/conform.nvim")

  -- Code linting
  use("mfussenegger/nvim-lint")
end)
