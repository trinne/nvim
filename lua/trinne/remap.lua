vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set("n", "<leader>pv", vim.cmd.NvimTreeToggle) -- vim.cmd.Ex
vim.keymap.set("n", "<leader>pf", vim.cmd.NvimTreeFindFile) -- vim.cmd.Ex

-- move lines when selected in visual mode. Indents if moved into if statements etc
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keep the cursor where it was
vim.keymap.set("n", "J", "mzJ`z")

-- keep the cursor in the middle of the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste, but dont yank the visually selected studff
vim.keymap.set("x", "<leader>p", '"_dPdNzzzv')

-- yank to system clipboard (+register) asbojornHaland
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- delete into the void register
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<M-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<M-j>", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
