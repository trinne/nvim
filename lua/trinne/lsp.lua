-- LSP behaviour shared by every server. Neovim's own defaults (:h lsp-defaults) stay active:
--   grn rename · gra code action · grr references · gri implementation · grt type definition
--   gO document symbols · K hover · <C-s> signature help (insert) · [d ]d diagnostics
--   <C-w>d diagnostic under the cursor · visual an / in grow / shrink selection
-- The mappings below keep the old habits and add pickers on top.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("trinne.lsp", { clear = true }),
  callback = function(ev)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    local P = Snacks.picker
    map("n", "gd", P.lsp_definitions, "Go to definition")
    map("n", "gD", P.lsp_declarations, "Go to declaration")
    map("n", "gi", P.lsp_implementations, "Go to implementation")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>fs", P.lsp_symbols, "Symbols (buffer)")
    map("n", "<leader>fS", P.lsp_workspace_symbols, "Symbols (workspace)")
    map("n", "<leader>fc", P.lsp_incoming_calls, "Incoming calls")
    map("n", "<leader>fo", P.lsp_outgoing_calls, "Outgoing calls")
    map("n", "<leader>fi", P.lsp_implementations, "Implementations")
    map("n", "<leader>rs", "<cmd>lsp restart<CR>", "Restart LSP")
    map("n", "<leader>ch", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
    end, "Toggle inlay hints")
  end,
})

-- grr opens the references in a picker instead of the quickfix list
vim.keymap.set("n", "grr", function()
  Snacks.picker.lsp_references()
end, { desc = "References" })

local severity = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = "if_many" },
  float = { source = true },
  signs = {
    text = {
      [severity.ERROR] = " ",
      [severity.WARN] = " ",
      [severity.HINT] = "󰠠 ",
      [severity.INFO] = " ",
    },
  },
})
