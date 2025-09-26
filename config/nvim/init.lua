-- Disable all default mappings from vim-tablemode
vim.g.table_mode_disable_mappings = 1

vim.deprecate = function() end

require("config.leader")

require("config.globals")
require("config.keymaps")
require("config.options")

require("config.plugins")
require("config.filetypes")

require("config.nvim_tree")
require("config.telescope_cfg")
require("config.blamer")

require("config.lualine")
require("config.treesitter")
require("config.cmp")
require("config.message_line")
require("config.indent")
require("config.format")

require("config.gitsigns")

require("config.lsp.setup")

require("config.autocmd")

vim.filetype.add({
    filename = {
        ["Jenkinsfile"] = "groovy",
    },
})

require("config.colorscheme")

require("config.enforce_tt_keymap")
