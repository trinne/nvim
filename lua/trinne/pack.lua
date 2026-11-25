-- All plugins, installed with the built-in vim.pack (:h vim.pack). Exact revisions are locked
-- in nvim-pack-lock.json; update with :PackUpdate, review, :write, then commit the lockfile.
-- One add() call so that a fresh install clones everything in parallel.

local function gh(repo, extra)
  return vim.tbl_extend("force", { src = "https://github.com/" .. repo }, extra or {})
end

-- Build hooks. Must be defined before vim.pack.add() so they also run on the first install.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("trinne.pack", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  -- UI
  gh("folke/tokyonight.nvim"),
  gh("gbprod/nord.nvim"),
  gh("catppuccin/nvim", { name = "catppuccin" }),
  gh("folke/snacks.nvim"), -- picker, explorer, lazygit, indent guides, notifications
  gh("folke/which-key.nvim"),
  gh("nvim-mini/mini.nvim"), -- icons, pairs
  gh("nvim-lualine/lualine.nvim"),

  -- Editing
  gh("nvim-treesitter/nvim-treesitter", { version = "main" }),
  gh("nvim-treesitter/nvim-treesitter-textobjects", { version = "main" }),
  gh("windwp/nvim-ts-autotag"),
  gh("saghen/blink.cmp", { version = vim.version.range("1.*") }), -- tagged release = prebuilt binary
  gh("rafamadriz/friendly-snippets"),
  gh("nvim-lua/plenary.nvim"),
  gh("ThePrimeagen/harpoon", { version = "harpoon2" }),
  gh("folke/todo-comments.nvim"),

  -- LSP and formatting
  gh("neovim/nvim-lspconfig"), -- server configs only (lsp/*.lua), enabled in lua/trinne/lsp.lua
  gh("mason-org/mason.nvim"),
  gh("folke/lazydev.nvim"),
  gh("stevearc/conform.nvim"),
  gh("mfussenegger/nvim-jdtls"),

  -- Git
  gh("lewis6991/gitsigns.nvim"),

  -- Debugging and testing
  gh("mfussenegger/nvim-dap"),
  gh("igorlfs/nvim-dap-view", { version = vim.version.range("1.*") }),
  gh("nvim-neotest/nvim-nio"),
  gh("nvim-neotest/neotest"),
  gh("marilari88/neotest-vitest"),
  gh("nvim-neotest/neotest-jest"),
  gh("rcasia/neotest-java"),

  -- Databases
  gh("tpope/vim-dadbod"),
  gh("kristijanhusak/vim-dadbod-ui"),
  gh("kristijanhusak/vim-dadbod-completion"),
}, { confirm = false })

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update plugins (review, then :write to apply)" })
