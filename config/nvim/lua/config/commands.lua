-- Define :DL {line}
vim.api.nvim_create_user_command("DL", function(opts)
	-- Save cursor position
	local pos = vim.api.nvim_win_get_cursor(0)
	-- Execute delete with whatever line expression was given
	vim.cmd("keepjumps " .. opts.args .. "delete")
	-- Restore cursor position
	vim.api.nvim_win_set_cursor(0, pos)
end, {
	nargs = 1, -- require exactly one argument
	complete = "command", -- let Vim handle line completion (so +10, -3, . etc. work)
})

-- Define :UD (Undo without moving cursor)
vim.api.nvim_create_user_command("UD", function()
	-- Save cursor position
	local pos = vim.api.nvim_win_get_cursor(0)
	-- Do an undo
	vim.cmd("undo")
	-- Restore cursor position (if still valid)
	local line_count = vim.api.nvim_buf_line_count(0)
	if pos[1] <= line_count then
		vim.api.nvim_win_set_cursor(0, pos)
	end
end, {
	nargs = 0, -- no args for undo
})
