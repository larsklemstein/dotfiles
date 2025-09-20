-- ~/.config/nvim/lua/config/format.lua
local ok, conform = pcall(require, "conform")
if not ok then
	return
end

conform.setup({
	notify_on_error = false, -- silence formatter popups
	formatters_by_ft = {
		lua = { "stylua" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		yaml = { "yamlfmt", "prettier" }, -- try yamlfmt first; fallback to prettier
	},
	formatters = {
		shfmt = { prepend_args = { "-i", "4", "-ci", "-ln", "bash" } },
	},
	-- Hard gate: only format these fts on save (even if another autocommand tries)
	format_on_save = function(bufnr)
		local ft = vim.bo[bufnr].filetype
		if ft == "lua" or ft == "sh" or ft == "bash" or ft == "yaml" then
			return { lsp_fallback = false, timeout_ms = 1000 }
		end
		return nil
	end,
})

-- Manual :Format command
vim.api.nvim_create_user_command("Format", function(args)
	local range
	if args.count ~= -1 then
		range = { start = vim.fn.getpos("'<")[2], ["end"] = vim.fn.getpos("'>")[2] }
	end
	conform.format({ async = false, lsp_fallback = false, range = range })
end, { range = true })
