-- Shared helpers for the headless checks. Each check exits non-zero on failure.
local M = {}

function M.fail(msg)
  io.stderr:write("FAIL " .. msg .. "\n")
  vim.cmd.cquit(1)
end

function M.ok(msg)
  io.stdout:write("ok   " .. msg .. "\n")
end

function M.expect(cond, msg)
  if cond then
    M.ok(msg)
  else
    M.fail(msg)
  end
end

--- Error lines from :messages
function M.errors()
  local errs = {}
  for _, l in ipairs(vim.split(vim.fn.execute("messages"), "\n")) do
    if l:match("E%d+:") or l:match("[Ee]rror") then
      errs[#errs + 1] = l
    end
  end
  return errs
end

return M
