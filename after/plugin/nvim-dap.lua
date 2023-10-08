require('dap.ext.vscode').load_launchjs()

local function nnoremap(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, {})
end

-- nvim-dap
nnoremap("<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Set breakpoint")
nnoremap("<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", "Set conditional breakpoint")
nnoremap("<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>", "Set log point")
nnoremap('<leader>br', "<cmd>lua require'dap'.clear_breakpoints()<cr>", "Clear breakpoints")
nnoremap('<leader>ba', '<cmd>Telescope dap list_breakpoints<cr>', "List breakpoints")

nnoremap("<leader>dc", "<cmd>lua require'dap'.continue()<cr>", "Continue")
nnoremap("<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", "Step over")
nnoremap("<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", "Step into")
nnoremap("<leader>do", "<cmd>lua require'dap'.step_out()<cr>", "Step out")
nnoremap('<leader>dd', "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect")
nnoremap('<leader>dt', "<cmd>lua require'dap'.terminate()<cr>", "Terminate")
nnoremap("<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", "Open REPL")
nnoremap("<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", "Run last")
nnoremap('<leader>di', function() require"dap.ui.widgets".hover() end, "Variables")
nnoremap('<leader>ds', function() local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes) end, "Scopes")
nnoremap('<leader>df', '<cmd>Telescope dap frames<cr>', "List frames")
nnoremap('<leader>dh', '<cmd>Telescope dap commands<cr>', "List commands")

local dap = require('dap')
dap.configurations.java = {
  {
    type = 'java';
    request = 'attach';
    name = "Debug (Attach) - Remote";
    hostName = "localhost";
    port = 5005;
  },
}
