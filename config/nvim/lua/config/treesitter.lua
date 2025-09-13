-- lua/config/treesitter.lua

local langs = { 'go','lua','python','typescript','tsx','json','yaml','bash' }

-- One-time setup, guarded so it runs only after the plugin is available
local configured = false
local function ts_setup()
  if configured then return end
  local ok_configs, configs = pcall(require, 'nvim-treesitter.configs')
  if not ok_configs then return end

  pcall(function() require('nvim-treesitter.install').prefer_git = true end)

  configs.setup({
    ensure_installed = langs,
    auto_install = true,
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent    = { enable = true, disable = { 'go' } }, -- TS indent OFF for Go
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
      },
    },
  })

  configured = true
end

-- Try once when UI is ready (in case plugin already loaded)
vim.api.nvim_create_autocmd('VimEnter', { callback = ts_setup })

-- And again when one of these filetypes opens (vim-plug loads the plugin here)
vim.api.nvim_create_autocmd('FileType', { pattern = langs, callback = ts_setup })

-- --- Go-specific indentation: use ONLY smartindent (no TS indent, no cindent) ---
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    -- ensure only one indent engine is active
    vim.opt_local.indentexpr  = ''      -- no TS indent function
    vim.opt_local.cindent     = false   -- disable cindent (prevents double indent)
    vim.opt_local.smartindent = true
    vim.opt_local.autoindent  = true

    -- gofmt/goimports settings
    vim.opt_local.expandtab   = false
    vim.opt_local.tabstop     = 8
    vim.opt_local.shiftwidth  = 0
    vim.opt_local.softtabstop = 0
  end,
})

