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
-- Load lint config after plugins are loaded
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("config.lint")
  end,
})

require("config.set_colorscheme")
