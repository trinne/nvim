-- Set a breakpoint at BREAK = { file, line }, start a debug session with START(run) and expect
-- the debugger to stop there with variable EXPECT_VAR visible.
local h = dofile(vim.fs.joinpath(vim.fn.stdpath("config"), "test/checks/helpers.lua"))
local dap = require("dap")
local stopped
dap.listeners.after.event_stopped["check"] = function(session, body)
  session:request("stackTrace", { threadId = body.threadId }, function(_, resp)
    local f = resp.stackFrames[1]
    session:request("scopes", { frameId = f.id }, function(_, sc)
      session:request("variables", { variablesReference = sc.scopes[1].variablesReference }, function(_, vars)
        stopped = { line = f.line, vars = vim.tbl_map(function(v)
          return v.name .. "=" .. v.value
        end, vars.variables) }
      end)
    end)
  end)
end
vim.cmd.edit(BREAK[1])
vim.api.nvim_win_set_cursor(0, { BREAK[2], 0 })
dap.toggle_breakpoint()
START(function(config)
  dap.run(config)
end)
vim.wait(300000, function()
  return stopped ~= nil
end, 200)
h.expect(stopped ~= nil, NAME .. ": stopped at the breakpoint")
h.expect(stopped.line == BREAK[2], NAME .. ": line " .. BREAK[2])
h.expect(
  vim.tbl_contains(stopped.vars, EXPECT_VAR),
  NAME .. ": variable " .. EXPECT_VAR .. " (" .. table.concat(stopped.vars, ", ") .. ")"
)
pcall(dap.terminate)
vim.wait(1000)
vim.cmd("qa!")
