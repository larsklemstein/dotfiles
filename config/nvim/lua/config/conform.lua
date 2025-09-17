-- ~/.config/nvim/lua/config/conform.lua
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },      -- Lua formatting
    python = { "ruff_format" }, -- Python formatting (optional)
    javascript = { "prettier" },
    typescript = { "prettier" },
  },
})

