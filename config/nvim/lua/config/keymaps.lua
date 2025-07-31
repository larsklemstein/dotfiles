vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<F1>', '<cmd>bprevious<CR>')
vim.keymap.set('n', '<F2>', '<cmd>bnext<CR>')

vim.keymap.set('n', '<F3>', '<cmd>tabprevious<CR>')
vim.keymap.set('n', '<F4>', '<cmd>tabnext<CR>')

vim.keymap.set('n', '<C-L>', ':nohls<CR><C-L>')

vim.keymap.set('n', '<C-P>', ':bprevious<CR>')
vim.keymap.set('n', '<C-N>', ':bnext<CR>')

-- scroll up/down while in insert mode
vim.keymap.set('i', '<C-e>', '<C-x><C-e>')
vim.keymap.set('i', '<C-y>', '<C-x><C-y>')

-- execute current buffer as local script
vim.keymap.set('n', '<F5>', '<cmd>!./%<CR>')

vim.keymap.set('n', '<C-C>', ':Commentary<CR>')

-- Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- jump keys for diagnostic issues
vim.keymap.set("n", "<right>", vim.diagnostic.goto_next)
vim.keymap.set("n", "<left>", vim.diagnostic.goto_prev)

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

