-- Neovim config: github.com/trinne/nvim. Requires Neovim 0.12+ (vim.pack, vim.lsp.config).
if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({ { "This config requires Neovim 0.12 or newer", "ErrorMsg" } }, true, {})
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("trinne.options")
require("trinne.keymaps")
require("trinne.autocmds")

-- Plugins: each module calls vim.pack.add() and configures what it added.
-- The order matters only where noted.
require("trinne.pack") -- install/update hooks, must run before any vim.pack.add()
require("trinne.plugins.ui") -- colorschemes, snacks, which-key, lualine
require("trinne.theme").setup()
require("trinne.plugins.editor")
require("trinne.plugins.treesitter")
require("trinne.plugins.completion")
require("trinne.plugins.lsp")
require("trinne.plugins.format")
require("trinne.plugins.git")
require("trinne.plugins.java")
require("trinne.plugins.debug")
require("trinne.plugins.test")
require("trinne.plugins.db")
require("trinne.lsp")
