require("config.globals")

require("config.keymaps")
require("config.options")

require("config.plugins_load")

require("config.nvim_tree")
require("config.telescope")
require("config.blamer")
-- require("config.copilot")
require("config.lualine")
require("config.lsp")
require("config.treesitter")
require("config.cmp")
require("config.message_line")

-- Load lint config after plugins are loaded
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("config.lint")
  end,
})

require("config.set_colorscheme")

-- Let nvim-cmp own completion UI
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")

vim.cmd('filetype plugin indent on')

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    pcall(vim.lsp.buf.format, { async = false })
  end,
})

