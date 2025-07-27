require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})


-- vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tt', ':NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tf', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
