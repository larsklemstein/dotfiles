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
require("config.cmp")
require("config.ray")
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

-- Hard-disable builtin popup/fuzzy if something else re-adds them
vim.cmd([[
  set completeopt-=preview
  set completeopt-=popup
  set completeopt-=fuzzy
]])

