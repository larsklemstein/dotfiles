local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fz', builtin.current_buffer_fuzzy_find, { desc = 'Telescope fuzzy find heregs' })
vim.keymap.set('n', '<leader>fr', builtin.registers, { desc = 'Telescope (find) registers' })
vim.keymap.set('n', '<leader>tm', builtin.man_pages, { desc = 'Telescope man pages' })


require('telescope').setup{
    defaults = {
      layout_strategy = 'vertical',
      layout_config = { height = 0.80, width = 0.80 },
    },
}
