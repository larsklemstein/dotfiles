-- ~/.config/nvim/lua/config/format.lua
local ok, conform = pcall(require, "conform")
if not ok then
	return
end
--
--

conform.setup({
	notify_on_error = false,

	formatters_by_ft = {
		lua = { "stylua" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		yaml = { "yamlfmt", "prettier" },
		groovy = { "npm-groovy-lint" }, -- use this
		json = { "prettier" },
		jsonc = { "prettier" }, -- JSON with comments
		terraform = { "terraform_fmt" },
		tfvars = { "terraform_fmt" }, -- handle variable files too
		tf = { "terraform_fmt" },
	},

	formatters = {
		shfmt = {
			prepend_args = { "-i", "4", "-ci", "-ln", "bash" },
		},
		["npm-groovy-lint"] = {
			command = "npm-groovy-lint",
			args = { "--format", "$FILENAME" }, -- no stdin, must run on file
			stdin = false,
		},
	},

	format_on_save = {
		lsp_fallback = false,
		timeout_ms = 5000,
	},
})

-- Normalize YAML booleans (yes/no/on/off/True/False) to true/false
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("yaml_bool_normalize", { clear = true }),
	pattern = { "*.yaml", "*.yml" },
	callback = function(args)
		local buf = args.buf
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		local changed = false

		local function normalize_value(val)
			local lower = val:lower()
			if lower == "yes" or lower == "on" or lower == "true" then
				return "true"
			elseif lower == "no" or lower == "off" or lower == "false" then
				return "false"
			end
			return val
		end

		for i, line in ipairs(lines) do
			local new = line

			-- skip quoted strings ("yes", 'no')
			if not line:match(":%s*['\"]") and not line:match("^%s*%-%s*['\"]") then
				-- key: value
				new = new:gsub("(:%s*)([%a]+)(%s*#?.*)$", function(prefix, val, suffix)
					return prefix .. normalize_value(val) .. suffix
				end)
				-- list item
				new = new:gsub("^(%s*%-%s*)([%a]+)(%s*#?.*)$", function(prefix, val, suffix)
					return prefix .. normalize_value(val) .. suffix
				end)
			end

			if new ~= line then
				lines[i] = new
				changed = true
			end
		end

		if changed then
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		end
	end,
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
