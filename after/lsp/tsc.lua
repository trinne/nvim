-- The native TypeScript 7 language server (`tsc --lsp`), only for projects that depend on
-- TypeScript 7+, always from the project's node_modules. Other projects get vtsls.
-- Replaces nvim-lspconfig's root_dir/cmd, whose version check misreads "Version 7.x.y".
local ts = require("trinne.typescript")

return {
  cmd = function(dispatchers, config)
    local bin = vim.fs.joinpath(config.root_dir, "node_modules", ".bin", "tsc")
    return vim.lsp.rpc.start({ bin, "--lsp", "--stdio" }, dispatchers)
  end,
  root_dir = function(bufnr, on_dir)
    if ts.native(bufnr) then
      on_dir(vim.fs.root(bufnr, "node_modules"))
    end
  end,
}
