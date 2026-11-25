-- Run the tests in FILE with <leader>tf; expect PASSED / FAILED counts.
local h = dofile(vim.fs.joinpath(vim.fn.stdpath("config"), "test/checks/helpers.lua"))
vim.cmd.edit(FILE)
vim.api.nvim_feedkeys(vim.keycode("<leader>tf"), "mx", false)
local neotest = require("neotest")
local counts, adapter
vim.wait(600000, function()
  for _, id in ipairs(neotest.state.adapter_ids()) do
    local c = neotest.state.status_counts(id, { buffer = vim.api.nvim_get_current_buf() })
    if c and c.running == 0 and (c.passed + c.failed) > 0 then
      counts, adapter = c, id:gsub(":.*", "")
      return true
    end
  end
end, 500)
h.expect(counts ~= nil, FILE .. ": tests ran")
h.expect(adapter == ADAPTER, FILE .. ": adapter " .. ADAPTER .. " (" .. tostring(adapter) .. ")")
h.expect(counts.passed == PASSED and counts.failed == FAILED,
  ("%s: %d passed, %d failed (want %d, %d)"):format(FILE, counts.passed, counts.failed, PASSED, FAILED))
vim.cmd("qa!")
