-- ~/.config/nvim/lua/config/flash_cfg.lua
local M = {}

function M.setup()
	require("flash").setup({
		labels = "asdfghjklqwertyuiopzxcvbnm",
		highlight = { backdrop = false }, -- don't dim the background
		jump = { autojump = false }, -- always show labels
		modes = {
			char = {
				enabled = true, -- enhanced f/t/F/T
				jump_labels = true,
				multi_line = false,
			},
			search = { enabled = false },
			treesitter = { enabled = false },
		},
	})

	local flash = require("flash")

	---------------------------------------------------------------------------
	-- Enhanced motions: only in operator-pending (o) and visual (x) modes
	---------------------------------------------------------------------------
	vim.keymap.set({ "x", "o" }, "f", function()
		flash.jump({ mode = "char", search = { forward = true, wrap = false } })
	end, { desc = "Flash f" })

	vim.keymap.set({ "x", "o" }, "F", function()
		flash.jump({ mode = "char", search = { forward = false, wrap = false } })
	end, { desc = "Flash F" })

	vim.keymap.set({ "x", "o" }, "t", function()
		flash.jump({
			mode = "char",
			search = { forward = true, wrap = false },
			jump = { pos = "start" }, -- like native 't'
		})
	end, { desc = "Flash t" })

	vim.keymap.set({ "x", "o" }, "T", function()
		flash.jump({
			mode = "char",
			search = { forward = false, wrap = false },
			jump = { pos = "start" }, -- like native 'T'
		})
	end, { desc = "Flash T" })

	---------------------------------------------------------------------------
	-- Optional extras
	---------------------------------------------------------------------------
	vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash jump" })
	vim.keymap.set({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash Treesitter" })
	vim.keymap.set("o", "r", flash.remote, { desc = "Flash remote" })
	vim.keymap.set({ "o", "x" }, "R", flash.treesitter_search, { desc = "Flash Treesitter Search" })

	---------------------------------------------------------------------------
	-- Highlight groups
	---------------------------------------------------------------------------
	vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ff0000", bold = true, nocombine = true })
	vim.api.nvim_set_hl(0, "FlashMatch", { underline = true, nocombine = true })
end

return M
