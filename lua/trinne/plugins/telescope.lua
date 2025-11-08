return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.load_extension("ui-select")
    telescope.load_extension("fzf")
    telescope.load_extension("dap")
    telescope.load_extension("harpoon")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        dynamic_preview_title = true,
        mappings = {
          i = {
            ["<leader>ftq"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<leader>ft"] = trouble_telescope.open,
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },

        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
      },
    })

    local builtin = require("telescope.builtin")
    local keymap = vim.keymap
    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find in open buffer" })
    keymap.set("n", "<leader>fm", builtin.marks, { desc = "Find in marks" })
    keymap.set("n", "gr", builtin.lsp_references, { desc = "Find references for function under cursor" })
    keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find symbols" })
    keymap.set(
      "n",
      "<leader>fc",
      builtin.lsp_incoming_calls,
      { desc = "Find incoming calls for function under cursor" }
    )
    keymap.set(
      "n",
      "<leader>fo",
      builtin.lsp_outgoing_calls,
      { desc = "Find outgoing calls for function under cursor" }
    )
    keymap.set(
      "n",
      "<leader>fi",
      builtin.lsp_implementations,
      { desc = "find implementations for function under cursor" }
    )
    keymap.set("n", "<leader>fx", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Telescope diagnostics" })
    keymap.set("n", "<leader>ne", function()
      builtin.find_files({
        cwd = "~/.dotfiles/nvim/.config",
      })
    end, { desc = "Find form nvim config" })
    keymap.set("n", "<C-p>", builtin.git_files, { desc = "Find in current git project" })
    keymap.set("n", "<leader>ps", function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end, { desc = "Find string under cursor in cwd" })
  end,
}
