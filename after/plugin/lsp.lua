local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})

  vim.keymap.set('n', 'gr', vim.lsp.buf.references, {noremap=true, silent=true, buffer=bufnr, desc="Go to reference"})
  vim.keymap.set('n','<leader>rn', vim.lsp.buf.rename, { noremap=true, silent=true, buffer=bufnr, desc = "Rename" })
  vim.keymap.set('n','<leader>ca', vim.lsp.buf.code_action, { noremap=true, silent=true, buffer=bufnr, desc = "Code actions" } )
  vim.keymap.set('v', "<leader>ca", "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
    { noremap=true, silent=true, buffer=bufnr, desc = "Code actions" })
end)

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true }
})

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

require 'lspconfig'.eslint.setup({
    settings = {
        packageManager = 'npm'
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
        })
    end,
})
require('lspconfig').tsserver.setup({
  on_attach = function(client, bufnr)
      require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
  end,
  single_file = false,
})
require'lspconfig'.helm_ls.setup{}
require'lspconfig'.bashls.setup{}
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


lsp.setup()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

-- (Optional) Icons for completions
local lspkind = require('lspkind')

-- Show error in popup
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { noremap = true, silent = true })

cmp.setup({
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'vsnip' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  }),
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- because we are using the vsnip cmp plugin
    end,
  },
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- Navigate docs
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-u>'] = cmp.mapping.scroll_docs(4),

    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '...',
      before = function (_, vim_item)
        return vim_item
      end
    })
  }
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
--    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
--    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
       -- { name = 'cmdline' }
    })
})
