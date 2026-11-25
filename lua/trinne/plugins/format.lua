-- Formatting with conform.nvim, on save and with <leader>cf.
--
-- Web files use whichever formatter the project is set up for, looked up from the file
-- upwards: biome (biome.json) → oxfmt (.oxfmtrc.json / oxfmt.config.ts) → prettier.
-- The binaries come from the project's node_modules/.bin first, mason second.
local conform = require("conform")

local web_formatters = {
  { name = "biome", markers = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" } },
  { name = "oxfmt", markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" } },
}

local function web(bufnr)
  for _, f in ipairs(web_formatters) do
    if vim.fs.root(bufnr, f.markers) then
      return { f.name }
    end
  end
  return { "prettierd", "prettier", stop_after_first = true }
end

local by_ft = {
  lua = { "stylua" },
  sh = { "shfmt" },
  bash = { "shfmt" },
  zsh = {},
  python = { "ruff_organize_imports", "ruff_format" },
  kotlin = { "ktlint" },
  toml = { "taplo" },
}
for _, ft in ipairs({
  "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "astro",
  "json", "jsonc", "css", "scss", "less", "html", "graphql", "markdown", "yaml",
}) do
  by_ft[ft] = web
end

conform.setup({
  formatters_by_ft = by_ft,
  default_format_opts = { lsp_format = "fallback" }, -- e.g. Java (jdtls), Clojure (clojure-lsp)
  format_on_save = function(bufnr)
    if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
      return
    end
    return { timeout_ms = 3000 }
  end,
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  conform.format({ async = true })
end, { desc = "Format buffer / selection" })

vim.keymap.set("n", "<leader>cF", function()
  vim.g.autoformat = vim.g.autoformat == false
  vim.notify("Format on save " .. (vim.g.autoformat and "enabled" or "disabled"))
end, { desc = "Toggle format on save" })

-- <leader>ci: which language servers and which formatter this buffer uses
vim.keymap.set("n", "<leader>ci", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = { "Language servers:" }
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    lines[#lines + 1] = ("  %s  (%s)"):format(c.name, c.root_dir or "single file")
  end
  local fmts, lsp = conform.list_formatters_to_run(bufnr)
  lines[#lines + 1] = "Formatter:"
  for _, f in ipairs(fmts) do
    lines[#lines + 1] = ("  %s  (%s)"):format(f.name, f.command or "")
  end
  if #fmts == 0 then
    lines[#lines + 1] = lsp and "  LSP" or "  none"
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Tools for this buffer" })
end, { desc = "Tools for this buffer" })
