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
        require("neotest-java"),
        require("neotest-vim-test")({
            ignore_file_types = { "python", "vim", "lua", "java", "javascript", "typescript" },
        }),
        require("neotest-vitest")({
            dap = { justMyCode = false }
        }),
    },
})
