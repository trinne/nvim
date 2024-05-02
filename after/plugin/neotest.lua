local neotest = require("neotest")

vim.keymap.set('n', '<leader>t', function()
    neotest.run.run()
end)

vim.keymap.set('n', '<leader>T', function()
    neotest.run.run(vim.fn.expand("%"))
end)

vim.keymap.set('n', '<leader>td', function()
    neotest.run.run({strategy="dap"})
end)

local neotest_ns = vim.api.nvim_create_namespace "neotest"
vim.diagnostic.config({
    virtual_text = {
        format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
        end,
    },
}, neotest_ns)

neotest.setup({
    adapters = {
        require("neotest-plenary"),
        require("neotest-java")({
            -- function to determine which runner to use based on project path
            determine_runner = function(project_root_path)
                -- return should be "maven" or "gradle"
                return "gradle"
            end,
            -- override the builtin runner discovery behaviour to always use given
            -- tool. Default is "nil", so no override
            force_runner = nil,
            -- if the automatic runner discovery can't uniquely determine whether
            -- to use Gradle or Maven, fallback to using this runner. Default is
            -- "gradle"
            fallback_runner = "gradle"
        }),
        require("neotest-vim-test")({
            ignore_file_types = { "python", "vim", "lua", "java", "javascript", "typescript" },
        }),
        require("neotest-vitest")({
            dap = { justMyCode = false }
        }),
    },
})
