-- ~/.config/nvim/lua/config/lint.lua

-- Check if nvim-lint is available before configuring
local ok, lint = pcall(require, "lint")
if not ok then
	vim.notify("nvim-lint plugin not found", vim.log.levels.WARN)
	return
end

-- Configure linters per filetype
lint.linters_by_ft = {
	python = { "ruff" },
	yaml = { "yamllint" },
	go = { "golangcilint" },
	rust = { "clippy" },
	terraform = { "tflint" }, -- Terraform HCL
	tf = { "tflint" }, -- alias
	tfvars = { "tflint" }, -- alias
	markdown = { "markdownlint" },
}

-- Customize golangci-lint args
local goci = lint.linters.golangcilint
if goci then
	goci.args = {
		"run",
		"--output.json.path=stdout",
		"--show-stats=false",
		"--issues-exit-code",
		"0",
	}
end

-- ✅ Configure markdownlint to use stdin (needs classic CLI)
local md = lint.linters.markdownlint
if md then
	md.cmd = "/opt/homebrew/bin/markdownlint" -- full path to classic CLI
	md.stdin = true
	md.args = { "--stdin" }
end

-- 🔑 Autocmds to trigger linting and clear old diagnostics
vim.api.nvim_create_augroup("cfg_lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" }, {
	group = "cfg_lint",
	callback = function(args)
		local bufnr = args.buf
		local ft = vim.bo[bufnr].filetype

		lint.try_lint()

		-- Force clear diagnostics if a linter produced nothing
		vim.defer_fn(function()
			local linters = lint.linters_by_ft[ft] or {}
			for _, linter in ipairs(linters) do
				local name = nil
				if type(linter) == "string" then
					name = linter
				elseif type(linter) == "table" and type(linter.linter) == "string" then
					name = linter.linter
				end
				if name then
					local ns = lint.get_namespace(name)
					local diags = vim.diagnostic.get(bufnr, { namespace = ns })
					if vim.tbl_isempty(diags) then
						vim.diagnostic.reset(ns, bufnr)
					end
				end
			end
		end, 200)
	end,
})

-- Optional: manual trigger
vim.api.nvim_create_user_command("LintNow", function()
	lint.try_lint()
end, { desc = "Run nvim-lint for current buffer" })
