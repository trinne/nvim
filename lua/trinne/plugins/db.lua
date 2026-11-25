-- Databases: vim-dadbod-ui (<leader>D). Add connections in the UI (saved under
-- stdpath("data")/db_ui, not in git) or start nvim with $DATABASE_URL set. Queries run on save
-- or with <leader>S; SQL completion (tables, columns) comes through blink.cmp.
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_save_location = vim.fs.joinpath(vim.fn.stdpath("data"), "db_ui")
vim.g.db_ui_env_variable_url = "DATABASE_URL"

vim.keymap.set("n", "<leader>D", "<cmd>DBUIToggle<CR>", { desc = "Database UI" })
