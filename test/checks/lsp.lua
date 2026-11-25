-- Open FILE in the current project; expect language servers WANT, at least MIN_DIAG
-- diagnostics and FORMATTER as the formatter.
local h = dofile(vim.fs.joinpath(vim.fn.stdpath("config"), "test/checks/helpers.lua"))
vim.cmd.edit(FILE)
local function names()
  local n = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
  table.sort(n)
  return n
end
vim.wait(60000, function()
  for _, w in ipairs(WANT) do
    if not vim.tbl_contains(names(), w) then return false end
  end
  return #vim.diagnostic.get(0) >= (MIN_DIAG or 0)
end, 500)
for _, w in ipairs(WANT) do
  h.expect(vim.tbl_contains(names(), w), FILE .. ": " .. w .. " attached (" .. table.concat(names(), ",") .. ")")
end
for _, u in ipairs(UNWANTED or {}) do
  h.expect(not vim.tbl_contains(names(), u), FILE .. ": " .. u .. " not attached")
end
h.expect(#vim.diagnostic.get(0) >= (MIN_DIAG or 0), FILE .. ": diagnostics " .. #vim.diagnostic.get(0))
if (FORMATTER or "lsp") == "lsp" then -- servers like jdtls register formatting after startup
  vim.wait(60000, function() return select(2, require("conform").list_formatters_to_run(0)) end, 500)
end
if FORMATTER then -- nil: formatted by the language server
  local fmts = require("conform").list_formatters_to_run(0)
  local got = fmts[1] and fmts[1].name or "none"
  h.expect(got == FORMATTER, FILE .. ": formatter " .. FORMATTER .. " (" .. got .. ")")
end
vim.cmd("qa!")
