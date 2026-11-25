-- Completion: blink.cmp. Sources: LSP, snippets (friendly-snippets + LSP), path, buffer;
-- lazydev for the Neovim Lua API, dadbod for SQL.
require("lazydev").setup({
  library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
})

require("blink.cmp").setup({
  -- Same keys as before: <CR> accepts, <C-Space> opens, <C-n>/<C-p> select, <C-d>/<C-u> scroll docs
  keymap = {
    preset = "enter",
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  signature = { enabled = true }, -- parameter hints while typing (<C-k> toggles)
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      lua = { inherit_defaults = true, "lazydev" },
      sql = { "dadbod", "snippets", "buffer" },
      mysql = { "dadbod", "snippets", "buffer" },
      plsql = { "dadbod", "snippets", "buffer" },
    },
    providers = {
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
