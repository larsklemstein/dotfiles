-- ~/.config/nvim/lua/config/format.lua
local ok, conform = pcall(require, "conform")
if not ok then
	return
end

conform.setup({
	notify_on_error = false,

	-- Map filetypes to formatters
	formatters_by_ft = {
		lua = { "stylua" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		yaml = { "yamlfmt", "prettier" }, -- try yamlfmt first, fallback to prettier
	},

	-- Formatter definitions
	formatters = {
		shfmt = {
			prepend_args = { "-i", "4", "-ci", "-ln", "bash" },
		},
	},

	-- Global format on save: only runs for supported filetypes above
	format_on_save = {
		lsp_fallback = false,
		timeout_ms = 5000,
	},
})

-- Manual :Format command
vim.api.nvim_create_user_command("Format", function(args)
	local range
	if args.count ~= -1 then
		range = {
			start = vim.fn.getpos("'<")[2],
			["end"] = vim.fn.getpos("'>")[2],
		}
	end
	conform.format({ async = false, lsp_fallback = false, range = range })
end, { range = true })

-- Put this in your config (e.g. after conform setup or in a separate lua file)
vim.api.nvim_create_user_command("GroovyFormat", function()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("No file name for buffer", vim.log.levels.ERROR)
		return
	end

	-- Run npm-groovy-lint in place
	vim.cmd("silent !npm-groovy-lint --format " .. vim.fn.shellescape(file) .. " -o " .. vim.fn.shellescape(file))
	vim.cmd("edit!") -- reload buffer from disk
	vim.notify("Groovy formatted with npm-groovy-lint", vim.log.levels.INFO)
end, { desc = "Format current Groovy file with npm-groovy-lint" })
