-- Plugin for errors and warnings
return {
  {
    "folke/trouble.nvim",
    dependencies = { { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" } },
    opts = {
      focus = true
    },
    cmd = "Trouble",
    keys = {
      { "<leader>tt", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
    }
  },
}
