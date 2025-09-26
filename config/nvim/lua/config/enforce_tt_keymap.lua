-- nuke any global TableMode grabs, then set ours
pcall(vim.keymap.del, "n", "<leader>tt")
pcall(vim.keymap.del, "n", "<leader>tf")
vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFindFileToggle<CR>", { noremap = true, silent = true })

-- if TableMode adds *buffer-local* maps later, delete them whenever a buffer loads,
-- then re-apply ours so they always win.
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		pcall(vim.keymap.del, "n", "<leader>tt", { buffer = 0 })
		pcall(vim.keymap.del, "n", "<leader>tf", { buffer = 0 })
		vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, buffer = 0 })
		vim.keymap.set(
			"n",
			"<leader>tf",
			"<cmd>NvimTreeFindFileToggle<CR>",
			{ noremap = true, silent = true, buffer = 0 }
		)
	end,
})
