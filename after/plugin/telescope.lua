local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fm", builtin.marks, {})
vim.keymap.set("n", "gr", builtin.lsp_references, {})
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, {})
vim.keymap.set("n", "<leader>fc", builtin.lsp_incoming_calls, {})
vim.keymap.set("n", "<leader>fo", builtin.lsp_outgoing_calls, {})
vim.keymap.set("n", "<leader>fi", builtin.lsp_implementations, {})
vim.keymap.set("n", "<leader>fx", "<cmd>Telescope diagnostics bufnr=0<cr>")
vim.keymap.set("n", "<leader>ne", function()
  builtin.find_files({
    cwd = "~/.dotfiles/nvim/.config",
  })
end)
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

-- This is your opts table
require("telescope").setup({
  defaults = {
    path_display = {
      shorten = {
        len = 3,
        exclude = { 1, -1 },
      },
      truncate = true,
    },
    dynamic_preview_title = true,
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },

    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
  },
})

require("telescope").load_extension("ui-select")
require("telescope").load_extension("fzf")
require("telescope").load_extension("dap")
require("telescope").load_extension("harpoon")
