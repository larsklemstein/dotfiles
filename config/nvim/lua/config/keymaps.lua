vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<C-L>", ":nohls<CR><C-L>")

vim.keymap.set("n", "<C-P>", ":bprevious<CR>")
vim.keymap.set("n", "<C-N>", ":bnext<CR>")

-- scroll up/down while in insert mode
vim.keymap.set("i", "<C-e>", "<C-x><C-e>")
vim.keymap.set("i", "<C-y>", "<C-x><C-y>")

vim.keymap.set("n", "<C-C>", ":Commentary<CR>")

-- quit options
vim.keymap.set("n", "<leader>qq", ":qa<CR>")
vim.keymap.set("n", "<leader>qw", ":xa<CR>")
vim.keymap.set("n", "<leader>ww", ":close<CR>")

-- Handy diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- code action
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
-- Extra keymap: vsplit definition
--
vim.keymap.set("n", "<leader>vd", function()
	vim.cmd("vsplit")
	vim.lsp.buf.definition()
end, { desc = "LSP definition in vsplit" })

-- vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tt', ':NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tf', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
