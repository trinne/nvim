-- Startup has no errors, every theme loads, core modules work.
local h = dofile(vim.fs.joinpath(vim.fn.stdpath("config"), "test/checks/helpers.lua"))
vim.wait(1000)
local errs = h.errors()
h.expect(#errs == 0, "startup without errors " .. table.concat(errs, " | "))

local theme = require("trinne.theme")
for name, scheme in pairs(theme.colorschemes) do
  theme.apply(name)
  h.expect(vim.g.colors_name == scheme, "theme " .. name)
end
for _, cmd in ipairs({ "DBUI", "DapViewToggle", "Mason", "PackUpdate" }) do
  h.expect(vim.fn.exists(":" .. cmd) == 2, "command :" .. cmd)
end
vim.cmd.edit(vim.fs.joinpath(vim.fn.stdpath("config"), "init.lua"))
vim.wait(5000, function() return vim.treesitter.highlighter.active[0] ~= nil end)
h.expect(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil, "treesitter highlighting (lua)")
vim.cmd("qa!")
