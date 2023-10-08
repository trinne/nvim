require("symbols-outline").setup {
  auto_close = true,
}
vim.keymap.set('n', '<leader>cs', vim.cmd.SymbolsOutline) 
