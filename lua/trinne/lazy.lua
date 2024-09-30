-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    spec = {

        { -- Telescope
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            -- or                              , branch = '0.1.x',
            dependencies = {
                "nvim-lua/plenary.nvim",
                { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
                "nvim-telescope/telescope-ui-select.nvim" },
        },

        { -- Harpoon
            "ThePrimeagen/harpoon",
            branch = "harpoon2",
            dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
        },

        -- Filetree
        "nvim-tree/nvim-tree.lua",

        -- History
        "mbbill/undotree",

        -- GIT
        "tpope/vim-fugitive",
        "lewis6991/gitsigns.nvim",

        { -- Syntax Highlight, edit, and navigate code
            "nvim-treesitter/nvim-treesitter",
            build = function()
                pcall(require("nvim-treesitter.install").update({ with_sync = true }))
            end,
            dependencies = {
                "nvim-treesitter/nvim-treesitter-textobjects",
            },
        },
        { -- LSP Configuration & Plugins
            "neovim/nvim-lspconfig",
            dependencies = {
                -- Automatically install LSPs to stdpath for neovim
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",

                -- Useful status updates for LSP
                "j-hui/fidget.nvim",
            },
        },
        { -- Autocompletion
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "saadparwaiz1/cmp_luasnip",
                { "L3MON4D3/LuaSnip", run = "make install_jsregexp" },
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "onsails/lspkind.nvim",
            },
            config = function()
                -- nvim-cmp setup
                local cmp = require("cmp")
                -- (Optional) Icons for completions
                local lspkind = require("lspkind")

                vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true })

                cmp.setup({
                    view = {
                        entries = "native",
                    },
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        -- `Enter` key to confirm completion
                        ["<CR>"] = cmp.mapping.confirm({
                            behavior = cmp.ConfirmBehavior.Insert,
                            select = true,
                        }),

                        -- Ctrl+Space to trigger completion menu
                        ["<C-Space>"] = cmp.mapping.complete(),

                        -- Navigate docs
                        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                        ["<C-u>"] = cmp.mapping.scroll_docs(4),

                        ["<C-n>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                        ["<C-p>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                    }),
                    formatting = {
                        format = lspkind.cmp_format({
                            mode = "symbol_text",
                            maxwidth = 50,
                            ellipsis_char = "...",
                            before = function(_, vim_item)
                                return vim_item
                            end,
                        }),
                    },
                    sources = {
                        { name = "nvim_lsp" },
                        { name = "nvim_lsp_signature_help" },
                        { name = "vsnip" },
                        { name = "luasnip" },
                        { name = "buffer" },
                    },
                })

                -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
                cmp.setup.cmdline({ "/", "?" }, {
                    --    mapping = cmp.mapping.preset.cmdline(),
                    sources = {
                        { name = "buffer" },
                    },
                })

                -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
                cmp.setup.cmdline(":", {
                    --    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({
                        { name = "path" },
                    }, {
                        -- { name = 'cmdline' }
                    }),
                })
            end,
        },
        -- Sonarlint
        "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",

        -- Github CoPilot
        "github/copilot.vim",

        -- Code structure
        "simrat39/symbols-outline.nvim",

        -- Debugging
        "mfussenegger/nvim-dap",
        {
            "rcarriga/nvim-dap-ui",
            dependencies = {
                "mfussenegger/nvim-dap",
                "folke/neodev.nvim",
            },
        },
        {
            "nvim-telescope/telescope-dap.nvim",
            dependencies = {
                { "mfussenegger/nvim-dap" },
                { "nvim-telescope/telescope.nvim" },
                { "nvim-treesitter/nvim-treesitter" },
            },
        },

        -- Java language server tools
        "mfussenegger/nvim-jdtls",

        -- SQL
        "tpope/vim-dadbod",
        "kristijanhusak/vim-dadbod-ui",
        "kristijanhusak/vim-dadbod-completion",

        -- Errors and warnings
        {
            "folke/trouble.nvim",
            dependencies = { { "nvim-tree/nvim-web-devicons" } },
        },
        -- Projectwide diagnostics
        { "artemave/workspace-diagnostics.nvim" },

        -- Test
        {
            "nvim-neotest/neotest",
            dependencies = {
                "nvim-neotest/nvim-nio",
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
                "antoinemadec/FixCursorHold.nvim",
                "nvim-neotest/neotest-plenary",
                "nvim-neotest/neotest-vim-test",
                "andy-bell101/neotest-java",
                "marilari88/neotest-vitest",
                "vim-test/vim-test",
            },
        },

        -- Theme
        "folke/tokyonight.nvim",

        -- Bottom toolbar
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
        },

        -- Todo comments
        {
            "folke/todo-comments.nvim",
            dependencies = { "nvim-lua/plenary.nvim" },
        },

        -- Code formatting
        "stevearc/conform.nvim",

        -- Code linting
        "mfussenegger/nvim-lint",
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "folke/tokyonight.nvim", "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
