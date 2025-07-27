
-- use CTRL-J to accept Copilot suggestions
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

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

if vim.env.SSH_CLIENT and vim.env.SSH_CLIENT:match('^10%.0%.112%.71 ') then
  vim.cmd('colorscheme habamax')
  print('Using habamax colorscheme')
end

-- use CTRL-J to accept Copilot suggestions
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

-- disable Copilot if file $HOME/.config/nvim/copilot_disabled exists
if vim.fn.filereadable(vim.env.HOME .. '/.copilot_disabled') == 1 then
  vim.g.copilot_enabled = false
else
  vim.g.copilot_enabled = true
end
