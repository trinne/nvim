require("prettier").setup({
  bin = 'prettierd', -- or `'prettier'` (v0.23.3+)
  filetypes = {
    "css",
    "graphql",
    "html",
    "java",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "scss",
    "typescript",
    "typescriptreact",
    "yaml",
  },
})
