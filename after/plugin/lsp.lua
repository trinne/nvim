-- Setup mason so it can manage external tooling
require('mason').setup()
require("mason-lspconfig").setup({
    ensure_installed = { "kotlin_language_server", "eslint", "ts_ls", "bashls", "lua_ls" },
})

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
    library = { plugins = { "nvim-dap-ui" }, types = true },
})

-- (Optional) Configure lua language server for neovim
require("lspconfig").lua_ls.setup {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                    -- Depending on the usage, you might want to add additional paths here.
                    -- "${3rd}/luv/library"
                    -- "${3rd}/busted/library",
                }
                -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                -- library = vim.api.nvim_get_runtime_file("", true)
            }
        })
    end,
    settings = {
        Lua = {}
    }
}

require("lspconfig").eslint.setup({
    settings = {
        packageManager = "npm",
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
        })
    end,
})
require("lspconfig").ts_ls.setup({})
require("lspconfig").helm_ls.setup({})
require("lspconfig").bashls.setup({})
-- Sonarlint
--local sonar_language_server_path = require("mason-registry")
--                .get_package("sonarlint-language-server")
--                :get_install_path()
--local analyzers_path = sonar_language_server_path .. "/extension/analyzers"
--require('sonarlint').setup({
--    server = {
--       cmd = {
--          sonar_language_server_path .. "/sonarlint-language-server.cmd",
--          --'sonarlint-language-server',
--          -- Ensure that sonarlint-language-server uses stdio channel
--          '-stdio',
--          '-analyzers',
--          -- paths to the analyzers you need, using those for python and java in this example
--          -- vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
--          -- vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
--          -- vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjs.jar"),
--          -- vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
--          vim.fn.expand(analyzers_path .. "/sonarpython.jar"),
--          vim.fn.expand(analyzers_path .. "/sonarcfamily.jar"),
--          vim.fn.expand(analyzers_path .. "/sonarjs.jar"),
--          vim.fn.expand(analyzers_path .. "/sonarjava.jar"),
--       },
--       -- All settings are optional
--       settings = {
--          -- The default for sonarlint is {}, this is just an example
--          sonarlint = {}
--       }
--    },
--    filetypes = {
--        'typescript',
--        -- Requires nvim-jdtls, otherwise an error message will be printed
--        'java',
--    }
--})
