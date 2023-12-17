require("mason-lspconfig").setup {
    ensure_installed = { "kotlin_language_server", "jdtls", "eslint", "tsserver", "bashls", "lua_ls", "rust_analyzer" },
}
