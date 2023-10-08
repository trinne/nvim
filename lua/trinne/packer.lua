-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

    -- Finding files
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		-- or                            , branch = '0.1.x',
		requires = { {'nvim-lua/plenary.nvim'} }
	}
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use {'nvim-telescope/telescope-ui-select.nvim' }

    -- Filetree
    use 'nvim-tree/nvim-tree.lua'

    -- History
	use('mbbill/undotree')

    -- GIT
	use('tpope/vim-fugitive')
    use('lewis6991/gitsigns.nvim')

    -- Syntax highlight
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

    -- Language server
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		requires = {
			-- LSP Support
			{'neovim/nvim-lspconfig'},             -- Required
			{'williamboman/mason.nvim'},           -- Optional
			{'williamboman/mason-lspconfig.nvim'}, -- Optional

			-- Autocompletion
			{'hrsh7th/nvim-cmp'},     -- Required
			{'hrsh7th/cmp-nvim-lsp'}, -- Required
			{'L3MON4D3/LuaSnip'},     -- Required
            {'hrsh7th/cmp-vsnip'},
            {'hrsh7th/vim-vsnip'},
            {'onsails/lspkind.nvim'} -- Optional symbols in completions
		}
	}
    -- Code structure 
    use 'simrat39/symbols-outline.nvim'

    -- Debugging
    use 'mfussenegger/nvim-dap'
    use {
        "rcarriga/nvim-dap-ui",
        requires = {
            "mfussenegger/nvim-dap",
            'folke/neodev.nvim'
        }
    }
    use {
        'nvim-telescope/telescope-dap.nvim',
        requires = {
            {'mfussenegger/nvim-dap'},
            {'nvim-telescope/telescope.nvim'},
            {'nvim-treesitter/nvim-treesitter'}
        }
    }

    -- Java language server tools
    use 'mfussenegger/nvim-jdtls'
    use 'nvim-lua/plenary.nvim'

    -- Errors and warnings
    use {
        'folke/trouble.nvim',
        requires = { {'nvim-tree/nvim-web-devicons'} }
    }

    -- Test
    use 'vim-test/vim-test'
    use {
        'nvim-neotest/neotest',
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
            'antoinemadec/FixCursorHold.nvim',
            'nvim-neotest/neotest-plenary',
            'nvim-neotest/neotest-vim-test',
            'andy-bell101/neotest-java',
            'vim-test/vim-test'
        },
    }

    -- Theme
    use 'Mofiqul/dracula.nvim'
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    -- Code formatting
    use {
        'MunifTanjim/prettier.nvim',
        requires = {
            {'neovim/nvim-lspconfig'},
            {'jose-elias-alvarez/null-ls.nvim'}
        }
    }
end)

