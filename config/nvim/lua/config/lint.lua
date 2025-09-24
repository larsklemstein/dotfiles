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
}

-- Example customizations
-- lint.linters_by_ft['golangci-lint'].cmd = '/opt/homebrew/bin/golangci-lint'

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

-- 🔑 Autocmds to trigger linting
vim.api.nvim_create_autocmd({ "FileType", "BufWritePost", "InsertLeave" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
