-- ~/.config/nvim/init.lua

-- helper: safe require (won’t crash if a module/plugin is missing)
local function req(mod)
	local ok, m = pcall(require, mod)
	return ok and m or nil
end

-- 1) base config
req("config.globals")
req("config.keymaps")
req("config.options")

-- 2) plugins first
req("config.plugins_load")

-- 3) plugin configs (order only matters where deps exist)
req("config.nvim_tree")
req("config.telescope")
req("config.blamer")
-- req("config.copilot")
req("config.lualine")
req("config.treesitter")
req("config.cmp")
req("config.message_line")
req("config.indent")
req("config.format")

-- 4) LSP last (often references treesitter/cmp caps)
req("config.lsp")

-- 5) flash (“f on steroids”)
local flash_cfg = req("config.flash")
if flash_cfg and flash_cfg.setup then
	flash_cfg.setup()
end

-- 6) load lint config after startup (avoids blocking UI)
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("cfg_lint", { clear = true }),
	callback = function()
		req("config.lint")
	end,
})

-- 7) colorscheme (after plugins so highlights exist)
req("config.set_colorscheme")

-- 8) format Go on save (buffer-local, non-duplicating)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("fmt_go_on_save", { clear = true }),
	pattern = "*.go",
	callback = function()
		pcall(vim.lsp.buf.format, { async = false })
	end,
})

-- 9) Flash highlights (single source of truth, reapply on colorscheme)
do
	local function set_flash_hl()
		-- label = bright red (only labels)
		vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ff0000", bold = true, nocombine = true })
		-- match = subtle (don’t recolor the actual character)
		vim.api.nvim_set_hl(0, "FlashMatch", { underline = true, nocombine = true })
	end
	set_flash_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("flash_hl", { clear = true }),
		callback = set_flash_hl,
	})
end
