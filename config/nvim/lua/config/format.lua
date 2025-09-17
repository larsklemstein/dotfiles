-- ~/.config/nvim/lua/config/format.lua
local ok, conform = pcall(require, "conform")
if not ok then
	return
end

conform.setup({
	notify_on_error = true,
	-- Only wire formatters we actually want here (leave JS/TS/Python/Go to your current logic)
	formatters_by_ft = {
		lua = { "stylua" },
		sh = { "shfmt" }, -- covers .sh and most bash scripts (ft=sh)
	},
	formatters = {
		-- shfmt settings: 4 spaces, indent 'case', treat scripts as bash dialect
		shfmt = {
			prepend_args = { "-i", "4", "-ci", "-ln", "bash" },
			-- If you prefer tabs for shell, use: { "-i", "0", "-ci", "-ln", "bash" }
		},
		-- No args for stylua here; it will read your .stylua.toml (Tabs/Spaces, width, etc.)
	},
})

-- :Format command (current buffer or visual range)
vim.api.nvim_create_user_command("Format", function(args)
	local range
	if args.count ~= -1 then
		range = { start = vim.fn.getpos("'<")[2], ["end"] = vim.fn.getpos("'>")[2] }
	end
	conform.format({ async = false, lsp_fallback = false, range = range })
end, { range = true })

-- Format on save ONLY for Lua and shell to avoid conflicts with ESLint/Ruff/Go LSP formatters
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("conform_format_on_save", { clear = true }),
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if ft == "lua" or ft == "sh" or ft == "bash" then
			conform.format({ bufnr = args.buf, async = false, lsp_fallback = false })
		end
	end,
})
