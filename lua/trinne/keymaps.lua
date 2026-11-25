-- Core keymaps that need no plugins. Plugin keymaps live next to their plugin setup.
local map = vim.keymap.set

-- Move selected lines; re-indents when moved into blocks
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the cursor in place / centered
map("n", "J", "mzJ`z", { desc = "Join lines" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
map("n", "n", "nzzzv", { desc = "Next match" })
map("n", "N", "Nzzzv", { desc = "Previous match" })

-- Registers
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking the selection" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map("v", "<leader>d", [["_d]], { desc = "Delete without yanking" })

map("n", "Q", "<nop>")

-- Quickfix
map("n", "<M-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
map("n", "<M-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })

map("n", "<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Undo tree" })
