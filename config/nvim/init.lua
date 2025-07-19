-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.mouse = 'a'

vim.opt.showmode = true

vim.opt.updatecount = 0
vim.g.loaded_matchparen = false

-- disabled due super slow startup time on python3 files,
-- probably I need to replace this through another file detection plugin
vim.g.loaded_python3_provider = 0

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'


-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
-- vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 2


-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<F1>', '<cmd>bprevious<CR>')
vim.keymap.set('n', '<F2>', '<cmd>bnext<CR>')

vim.keymap.set('n', '<F3>', '<cmd>tabprevious<CR>')
vim.keymap.set('n', '<F4>', '<cmd>tabnext<CR>')

vim.keymap.set('n', '<C-L>', ':nohls<CR><C-L>')

-- scroll up/down while in insert mode
vim.keymap.set('i', '<C-e>', '<C-x><C-e>')
vim.keymap.set('i', '<C-y>', '<C-x><C-y>')

-- execute current buffer as local script
vim.keymap.set('n', '<F5>', '<cmd>!./%<CR>')


-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- Shorthand notation for GitHub; translates to https://github.com/junegunn/seoul256.vim.git

Plug 'nordtheme/vim'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-commentary'

Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'github/copilot.vim'

vim.call('plug#end')

-- set colorscheme dpeened on on env environment variable SSH_TERMINAL_IPAD
if vim.env.SSH_TERMINAL_IPAD then
  vim.cmd('colorscheme habamax')
else
  vim.cmd('colorscheme nord')
end 

-- disable Copilot if file $HOME/.config/nvim/copilot_disabled exists
if vim.fn.filereadable(vim.env.HOME .. '/.copilot_disabled') == 1 then
  vim.g.copilot_enabled = false
else
  vim.g.copilot_enabled = true
end

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- use CTRL-J to accept Copilot suggestions
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

-- use CTRL-D to deny Copilot suggestions
vim.keymap.set('i', '<C-D>', 'copilot#Dismiss()', {
  expr = true,
  replace_keycodes = false
})

-- use leader dc to toggle Copilot
vim.keymap.set('n', '<leader>cc', function()
  if not vim.g.copilot_enabled then
    vim.cmd('Copilot enable')
    vim.g.copilot_enabled = true
    print('Copilot enabled')
  else
    vim.cmd('Copilot disable')
    print('Copilot disabled')
    vim.g.copilot_enabled = false
  end
end, { desc = 'Toggle Copilot' })
