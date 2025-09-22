-- ~/.config/nvim/init.lua

-- helper: safe require (won’t crash if a module/plugin is missing)
local function req(mod)
	local ok, m = pcall(require, mod)
	return ok and m or nil
end

-- 1) base config
require("config.globals")
require("config.keymaps")
require("config.options")

-- 2) plugins first
require("config.plugins")

-- 3) plugin configs (order only matters where deps exist)
require("config.nvim_tree")
require("config.telescope_cfg")
require("config.blamer")
-- req("config.copilot")
require("config.lualine")
require("config.treesitter")
require("config.cmp")
require("config.message_line")
require("config.indent")
require("config.format")

-- 4) LSP last (often references treesitter/cmp caps)
require("config.lsp")

-- 6) load lint config after startup (avoids blocking UI)
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("cfg_lint", { clear = true }),
	callback = function()
		req("config.lint")
	end,
})

-- 7) colorscheme (after plugins so highlights exist)
req("config.colorscheme")

-- 8) format Go on save (buffer-local, non-duplicating)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("fmt_go_on_save", { clear = true }),
	pattern = "*.go",
	callback = function()
		pcall(vim.lsp.buf.format, { async = false })
	end,
})

vim.filetype.add({
	filename = {
		["Jenkinsfile"] = "groovy",
	},
})
