local mark, ui = require("harpoon.mark"), require("harpoon.ui")

vim.keymap.set('n', '<leader>hm', mark.add_file, {})
vim.keymap.set('n', '<leader>hu', ui.toggle_quick_menu, {})
vim.keymap.set('n', '<leader>ht', '<cmd>Telescope harpoon marks<cr>')
