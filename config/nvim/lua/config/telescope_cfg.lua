-- ~/.config/nvim/lua/config/telescope.lua

-- ~/.config/nvim/lua/config/telescope.lua
local ok, telescope = pcall(require, "telescope")
if not ok then
  return
end

local builtin = require("telescope.builtin")


-- Keymap helper with safe defaults
local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- Telescope pickers
map("n", "<leader>ff", builtin.find_files, "Telescope: Find files")
map("n", "<leader>fg", builtin.live_grep, "Telescope: Live grep")
map("n", "<leader>fb", builtin.buffers, "Telescope: Buffers")
map("n", "<leader>fh", builtin.help_tags, "Telescope: Help tags")
map("n", "<leader>fz", builtin.current_buffer_fuzzy_find, "Telescope: Fuzzy find in buffer")
map("n", "<leader>fr", builtin.registers, "Telescope: Registers")
map("n", "<leader>tm", builtin.man_pages, "Telescope: Man pages")

-- Setup with robust defaults
telescope.setup({
	defaults = {
		layout_strategy = "vertical",
		layout_config = {
			height = 0.80,
			width = 0.80,
			prompt_position = "top",
		},
		sorting_strategy = "ascending",
		mappings = {
			i = {
				["<C-q>"] = require("telescope.actions").smart_send_to_qflist
					+ require("telescope.actions").open_qflist,
				["<Esc>"] = require("telescope.actions").close,
			},
		},
	},
	pickers = {
		find_files = {
			hidden = true, -- show dotfiles
			follow = true, -- follow symlinks
		},
		live_grep = {
			additional_args = function()
				return { "--hidden" } -- include hidden files
			end,
		},
	},
})
