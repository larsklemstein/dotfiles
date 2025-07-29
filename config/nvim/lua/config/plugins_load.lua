local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug 'tpope/vim-commentary'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'github/copilot.vim'
Plug 'APZelos/blamer.nvim'
Plug 'mfussenegger/nvim-lint'
Plug 'kdheepak/lazygit.nvim'
Plug 'thesimonho/kanagawa-paper.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'folke/zen-mode.nvim'

vim.call('plug#end')
