-- Check if nvim-lint is available before configuring
local ok, lint = pcall(require, 'lint')

if not ok then
  vim.notify("nvim-lint plugin not found", vim.log.levels.WARN)
  return
end

lint.linters_by_ft = {
   python = { 'ruff' },
   yaml = { 'yamllint' },
   go = { 'golangcilint' },
   rust = { 'clippy' },
}

-- lint.linters_by_ft['golangci-lint'].cmd = '/opt/homebrew/bin/golangci-lint'

-- -- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
vim.api.nvim_create_autocmd({ "TextChanged" }, {
   callback = function()

     -- try_lint without arguments runs the linters defined in `linters_by_ft`
     -- for the current filetype
     lint.try_lint()

     -- You can call `try_lint` with a linter name or a list of names to always
     -- run specific linters, independent of the `linters_by_ft` configuration
   end,
})

local goci = lint.linters.golangcilint

goci.args = {
	"run",
	"--output.json.path=stdout",
	"--show-stats=false",
	"--issues-exit-code",
	"0",
}
