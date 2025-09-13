-- local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug 'tpope/vim-commentary'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'APZelos/blamer.nvim'
Plug 'mfussenegger/nvim-lint'
Plug 'kdheepak/lazygit.nvim'
Plug 'nvim-lualine/lualine.nvim'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'


-- Plug 'CopilotC-Nvim/CopilotChat.nvim'
-- Plug 'folke/flash.nvim'
Plug 'folke/tokyonight.nvim'
Plug 'vague2k/vague.nvim'
Plug 'lewis6991/gitsigns.nvim'

-- color schemes
Plug 'thesimonho/kanagawa-paper.nvim'
Plug 'Mofiqul/dracula.nvim'

Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

Plug 'ray-x/lsp_signature.nvim'



vim.call('plug#end')

-- require("CopilotChat").setup()
