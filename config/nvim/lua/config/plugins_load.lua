local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- Core
Plug 'neovim/nvim-lspconfig'
Plug('nvim-treesitter/nvim-treesitter', {
  ['do']  = ':TSUpdate',
  ['for'] = { 'go','lua','python','typescript','tsx','json','yaml','bash' } -- lazy by ft
})
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { ['cmd'] = 'Telescope' })       -- lazy on :Telescope
Plug('nvim-tree/nvim-tree.lua',       { ['on']  = 'NvimTreeToggle' })  -- lazy on :NvimTreeToggle
Plug 'nvim-tree/nvim-web-devicons'    -- optional (icons)
Plug('lewis6991/gitsigns.nvim',       { ['event'] = 'BufRead' })       -- lazy on first buffer read
Plug 'nvim-lualine/lualine.nvim'
Plug 'tpope/vim-commentary'
Plug('kdheepak/lazygit.nvim',         { ['cmd'] = 'LazyGit' })         -- lazy on :LazyGit

-- Completion + snippets
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'             -- optional (':' '/' '?')
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'

-- Linting
Plug('mfussenegger/nvim-lint',        { ['event'] = 'BufWritePost' })  -- lazy on save

-- Theme
Plug 'vague2k/vague.nvim'

vim.call('plug#end')
