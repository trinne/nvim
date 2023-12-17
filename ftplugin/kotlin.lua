local home = os.getenv('HOME')

-- Helper function for creating keymaps
local function nnoremap(lhs, rhs, bufopts, desc)
  bufopts.desc = desc
  vim.keymap.set("n", lhs, rhs, bufopts)
end

-- The on_attach function is used to set key maps after the language server
-- attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Regular Neovim LSP client keymappings
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  nnoremap('gD', vim.lsp.buf.declaration, bufopts, "Go to declaration")
  nnoremap('gd', vim.lsp.buf.definition, bufopts, "Go to definition")
  nnoremap('gi', vim.lsp.buf.implementation, bufopts, "Go to implementation")
  nnoremap('K', vim.lsp.buf.hover, bufopts, "Hover text")
  nnoremap('<C-k>', vim.lsp.buf.signature_help, bufopts, "Show signature")
  nnoremap('<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts, "Add workspace folder")
  nnoremap('<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts, "Remove workspace folder")
  nnoremap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts, "List workspace folders")
  nnoremap('<leader>D', vim.lsp.buf.type_definition, bufopts, "Go to type definition")
  nnoremap('<leader>rn', vim.lsp.buf.rename, bufopts, "Rename")
  nnoremap('<leader>ca', vim.lsp.buf.code_action, bufopts, "Code actions")
  vim.keymap.set('v', "<leader>ca", "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
    { noremap=true, silent=true, buffer=bufnr, desc = "Code actions" })
end

-- The nvim-cmp supports additional LSP's capabilities so we need to
-- advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local config = {
  flags = {
    debounce_text_changes = 80,
  },
  capabilities = capabilities,
  on_attach = on_attach,  -- We pass our on_attach keybindings to the configuration map
}

require'lspconfig'.kotlin_language_server.setup{ config }
