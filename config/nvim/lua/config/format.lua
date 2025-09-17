local conform = require("conform")

conform.setup({
	notify_on_error = true,
	formatters_by_ft = {
		lua = { "stylua" }, -- only Lua uses stylua
	},
})

-- format Lua on save (blocking, like your Ruff/ESLint setup)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("fmt_lua_on_save", { clear = true }),
	pattern = "*.lua",
	callback = function(args)
		conform.format({ bufnr = args.buf, async = false, lsp_fallback = false })
	end,
})
