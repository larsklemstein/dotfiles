--require("nvim-treesitter.configs").setup({
--  ensure_installed = { "c", "lua", "vim", "vimdoc", "yaml", "python", "rust"  },
-- })

-- lua/config/treesitter.lua
vim.g.ts_setup_done = false

local function ts_setup()
  if vim.g.ts_setup_done then return end
  local ok, configs = pcall(require, 'nvim-treesitter.configs')
  if not ok then return end

  configs.setup({
    ensure_installed = { 'go','lua','python','typescript','tsx','json','yaml','bash' },
    highlight = { enable = true },
    indent    = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
  })

  vim.g.ts_setup_done = true
end

-- Try once on startup (in case treesitter is already loaded)
vim.api.nvim_create_autocmd('VimEnter', { callback = ts_setup })

-- Ensure setup runs the moment a matching filetype loads the plugin
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go','lua','python','typescript','tsx','json','yaml','bash' },
  callback = ts_setup,
})
