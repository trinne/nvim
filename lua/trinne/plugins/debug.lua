-- Debugging: nvim-dap with the nvim-dap-view UI (opens and closes with the session).
--
-- Adapters (installed by mason, see lua/trinne/tools.lua):
--   JS/TS   vscode-js-debug (js-debug-adapter): Node launch/attach, Chrome attach, test runners
--   Java    java-debug via jdtls (configured in plugins/java.lua)
--   Kotlin  kotlin-debug-adapter: attach to a JVM started with JDWP on port 5005
-- A project's .vscode/launch.json is read too, so configurations shared with VS Code work.
local dap = require("dap")

require("dap-view").setup({
  auto_toggle = true,
  winbar = { default_section = "scopes", controls = { enabled = true } },
})
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "Visual" })

-- JavaScript / TypeScript -------------------------------------------------------------------
local js_debug = {
  type = "server",
  -- Explicit IPv4 on both ends: "localhost" may resolve to ::1 for one side only
  host = "127.0.0.1",
  port = "${port}",
  executable = { command = "js-debug-adapter", args = { "${port}", "127.0.0.1" } },
}
dap.adapters["pwa-node"] = js_debug
dap.adapters["pwa-chrome"] = js_debug
-- VS Code launch.json files use "node" / "chrome"; js-debug expects the pwa- names
for _, t in ipairs({ "node", "chrome" }) do
  dap.adapters[t] = function(cb, config)
    config.type = "pwa-" .. t
    cb(js_debug)
  end
end

local js_filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" }
local vscode = require("dap.ext.vscode")
for _, t in ipairs({ "node", "chrome", "pwa-node", "pwa-chrome" }) do
  vscode.type_to_filetypes[t] = js_filetypes
end

-- In a devbox container the browser runs on the host: attach to it through the host gateway
local host = vim.env.DEVBOX and "host.containers.internal" or "localhost"

local js_configs = {
  {
    name = "Node: launch current file",
    type = "pwa-node",
    request = "launch",
    program = "${file}", -- Node runs TypeScript directly (type stripping)
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
  },
  {
    name = "Node: attach (node --inspect, port 9229)",
    type = "pwa-node",
    request = "attach",
    address = "localhost",
    port = 9229,
    cwd = "${workspaceFolder}",
    restart = true, -- reattach when a dev server (tsx watch, nodemon) restarts
  },
  {
    name = "Chrome: attach (--remote-debugging-port=9222)",
    type = "pwa-chrome",
    request = "attach",
    address = function()
      return vim.fn.input("Chrome host: ", host)
    end,
    port = 9222,
    webRoot = "${workspaceFolder}",
  },
}
for _, ft in ipairs(js_filetypes) do
  dap.configurations[ft] = js_configs
end

-- Kotlin ------------------------------------------------------------------------------------
dap.adapters.kotlin = { type = "executable", command = "kotlin-debug-adapter", options = { auto_continue_if_many_stopped = false } }
dap.configurations.kotlin = {
  {
    name = "JVM: attach (port 5005)",
    type = "kotlin",
    request = "attach",
    projectRoot = "${workspaceFolder}",
    hostName = "localhost",
    port = 5005,
    timeout = 30000,
  },
}

-- Keymaps -----------------------------------------------------------------------------------
local map = vim.keymap.set
map("n", "<leader>bb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>bc", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>bl", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "Log point" })
map("n", "<leader>br", dap.clear_breakpoints, { desc = "Clear breakpoints" })
map("n", "<leader>ba", function()
  dap.list_breakpoints(true)
  Snacks.picker.qflist()
end, { desc = "List breakpoints" })

map("n", "<leader>dc", dap.continue, { desc = "Start / continue" })
map("n", "<leader>dj", dap.step_over, { desc = "Step over" })
map("n", "<leader>dk", dap.step_into, { desc = "Step into" })
map("n", "<leader>do", dap.step_out, { desc = "Step out" })
map("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to cursor" })
map("n", "<leader>dd", dap.disconnect, { desc = "Disconnect" })
map("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
map("n", "<leader>dl", dap.run_last, { desc = "Run last" })
map("n", "<leader>dr", "<cmd>DapViewShow repl<CR>", { desc = "REPL" })
map("n", "<leader>du", "<cmd>DapViewToggle<CR>", { desc = "Toggle debug view" })
map({ "n", "x" }, "<leader>di", "<cmd>DapViewWatch<CR>", { desc = "Watch expression" })
map("n", "<leader>ds", "<cmd>DapViewShow scopes<CR>", { desc = "Scopes" })
map("n", "<leader>df", "<cmd>DapViewShow threads<CR>", { desc = "Frames" })
