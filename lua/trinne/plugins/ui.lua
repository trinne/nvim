-- Colorschemes (picked by lua/trinne/theme.lua), snacks, which-key, icons and the statusline.
-- Backgrounds are transparent so the terminal's opacity shows through.
require("tokyonight").setup({ style = "storm", transparent = true, styles = { sidebars = "transparent" } })
require("nord").setup({ transparent = true })
require("catppuccin").setup({ flavour = "mocha", transparent_background = true })

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons() -- for plugins that expect nvim-web-devicons
require("mini.pairs").setup()

require("snacks").setup({
  bigfile = {}, -- plain mode for huge files
  explorer = { replace_netrw = true },
  indent = {},
  input = {}, -- vim.ui.input
  lazygit = {},
  notifier = {}, -- vim.notify
  picker = { ui_select = true }, -- also vim.ui.select (code actions etc.)
  quickfile = {},
  words = {}, -- highlight LSP references under the cursor, ]] / [[ to jump
})

local map = vim.keymap.set
local P = Snacks.picker

-- Find (pickers). Inside a picker: <C-q> sends the results to the quickfix list.
map("n", "<leader>ff", P.files, { desc = "Files" })
map("n", "<C-p>", P.git_files, { desc = "Git files" })
map("n", "<leader>fg", P.grep, { desc = "Grep" })
map("n", "<leader>ps", function()
  P.grep_word({ search = vim.fn.input("Grep > ") })
end, { desc = "Grep for a string" })
map({ "n", "x" }, "<leader>fw", P.grep_word, { desc = "Grep word / selection" })
map("n", "<leader>fb", P.buffers, { desc = "Buffers" })
map("n", "<leader>fm", P.marks, { desc = "Marks" })
map("n", "<leader>fr", P.recent, { desc = "Recent files" })
map("n", "<leader>fh", P.help, { desc = "Help" })
map("n", "<leader>fk", P.keymaps, { desc = "Keymaps" })
map("n", "<leader>fx", P.diagnostics_buffer, { desc = "Diagnostics (buffer)" })
map("n", "<leader>fX", P.diagnostics, { desc = "Diagnostics (all)" })
map("n", "<leader>fq", P.qflist, { desc = "Quickfix list" })
map("n", "<leader>fu", P.undo, { desc = "Undo history" })
map("n", "<leader>f.", P.resume, { desc = "Resume last picker" })
map("n", "<leader>fn", P.notifications, { desc = "Notifications" })
map("n", "<leader>ne", function()
  P.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Neovim config files" })

-- Explorer and lazygit
map("n", "<leader>pv", function()
  Snacks.explorer()
end, { desc = "File explorer" })
map("n", "<leader>pf", function()
  Snacks.explorer.reveal()
end, { desc = "Reveal file in explorer" })
map("n", "<leader>lg", function()
  Snacks.lazygit()
end, { desc = "Lazygit" })

require("which-key").setup({
  preset = "modern",
  spec = {
    { "<leader>b", group = "breakpoints" },
    { "<leader>c", group = "code" },
    { "<leader>d", group = "debug" },
    { "<leader>e", group = "extract (Java)" },
    { "<leader>f", group = "find" },
    { "<leader>h", group = "git hunks" },
    { "<leader>j", group = "harpoon" },
    { "<leader>n", group = "swap with next" },
    { "<leader>p", group = "explorer / swap with previous" },
    { "<leader>t", group = "test" },
    { "gr", group = "LSP" },
  },
})
map("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer keymaps" })

require("lualine").setup({
  options = { theme = "auto", globalstatus = true }, -- follows the active colorscheme
  sections = {
    lualine_x = { "lsp_status", "filetype" },
  },
})
