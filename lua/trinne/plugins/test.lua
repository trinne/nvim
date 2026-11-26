-- Tests with neotest. Each adapter recognises its own projects and files:
--   vitest / jest   by the project's package.json dependencies
--   Java            JUnit 5 through jdtls (neotest-java)
--   Kotlin          JUnit 5, kotlin.test and Kotest through Gradle (lua/trinne/neotest_gradle.lua)
-- Debugging a test (<leader>td) uses nvim-dap: js-debug for vitest/jest, java-debug for Java,
-- kotlin-debug-adapter for Kotlin.
-- Loaded on the first <leader>t keypress (the adapters take a while to load).
local loaded
local function neotest()
  if not loaded then
    -- neotest-java would also claim Kotlin test files (and fail to parse them)
    local java = require("neotest-java")({})
    local java_is_test_file = java.is_test_file
    java.is_test_file = function(path)
      return path:match("%.java$") ~= nil and java_is_test_file(path)
    end

    loaded = require("neotest")
    loaded.setup({
      adapters = {
        require("neotest-vitest"),
        require("neotest-jest")({
          -- The default lookup uses vim.fn.glob, which fails in neotest's async context
          jestConfigFile = function(path)
            local names = { "jest.config.ts", "jest.config.js", "jest.config.mjs", "jest.config.cjs" }
            return vim.fs.find(names, { path = path, upward = true })[1]
          end,
        }),
        java,
        require("trinne.neotest_gradle"),
      },
      output = { open_on_run = false },
      quickfix = { open = false },
    })
    -- neotest-java runs tests with the JUnit console launcher. Fetch it once (from Maven
    -- Central, checksum verified) instead of asking for :NeotestJava setup.
    local jar_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "neotest-java")
    local jars = vim.fn.glob(vim.fs.joinpath(jar_dir, "junit-platform-console-standalone-*.jar"), true, true)
    if #jars == 0 and vim.fn.executable("java") == 1 then
      local select = vim.ui.select
      vim.ui.select = function(choices, _, on_choice) -- answer its "download now?" with yes
        on_choice(choices[1])
      end
      pcall(java.install)
      vim.ui.select = select
    end
  end
  return loaded
end

local map = vim.keymap.set
local function key(lhs, desc, fn)
  map("n", lhs, function()
    fn(neotest())
  end, { desc = desc })
end
key("<leader>tt", "Run nearest test", function(n)
  n.run.run()
end)
key("<leader>tf", "Run tests in file", function(n)
  n.run.run(vim.fn.expand("%"))
end)
key("<leader>tl", "Run last", function(n)
  n.run.run_last()
end)
key("<leader>td", "Debug nearest test", function(n)
  n.run.run({ strategy = "dap" })
end)
key("<leader>tx", "Stop", function(n)
  n.run.stop()
end)
key("<leader>ts", "Summary", function(n)
  n.summary.toggle()
end)
key("<leader>to", "Output of nearest test", function(n)
  n.output.open({ enter = true, auto_close = true })
end)
key("<leader>tO", "Output panel", function(n)
  n.output_panel.toggle()
end)
key("<leader>tw", "Watch file", function(n)
  n.watch.toggle(vim.fn.expand("%"))
end)
key("]x", "Next failed test", function(n)
  n.jump.next({ status = "failed" })
end)
key("[x", "Previous failed test", function(n)
  n.jump.prev({ status = "failed" })
end)
