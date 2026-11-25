-- Harpoon (per-project file marks) and TODO comments.
local map = vim.keymap.set

local harpoon = require("harpoon")
harpoon:setup()
map("n", "<leader>ja", function()
  harpoon:list():add()
end, { desc = "Add file" })
map("n", "<leader>jj", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Menu" })
for i = 1, 4 do
  map("n", "<leader>" .. i, function()
    harpoon:list():select(i)
  end, { desc = "Harpoon file " .. i })
end

require("todo-comments").setup()
map("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next TODO" })
map("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous TODO" })
map("n", "<leader>ft", function()
  Snacks.picker.todo_comments()
end, { desc = "TODOs" })
