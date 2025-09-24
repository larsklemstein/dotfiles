-- ~/.config/nvim/lua/config/lsp.lua

-- 1) Completion UI: cmp owns it
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")
vim.cmd([[
  set completeopt-=preview
  set completeopt-=popup
  set completeopt-=fuzzy
]])

-- Disable Neovim native LSP completion UI
pcall(function()
	local ok = vim.lsp and vim.lsp.completion and vim.lsp.completion.enable
	if ok then
		vim.lsp.completion.enable(false)
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				vim.lsp.completion.enable(false, args.buf)
				vim.schedule(function()
					vim.opt_local.completeopt = { "menu", "menuone", "noselect" }
				end)
			end,
		})
	end
end)

-- Helpers
local au = vim.api.nvim_create_autocmd
local ag = function(name)
	return vim.api.nvim_create_augroup("lsp_" .. name, { clear = true })
end
local map = function(buf, mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true })
end

local function buf_format_with(name)
	vim.lsp.buf.format({
		async = false,
		filter = function(c)
			return c.name == name
		end,
	})
end

-- 2) Diagnostics look
vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = { source = "always" },
	update_in_insert = false,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.HINT] = "•",
			[vim.diagnostic.severity.INFO] = "○",
			[vim.diagnostic.severity.WARN] = "▲",
			[vim.diagnostic.severity.ERROR] = "✖",
		},
	},
	float = { source = "always" },
})
for name, color in pairs({
	DiagnosticSignError = "#ff5555",
	DiagnosticSignWarn = "#ffb86c",
	DiagnosticSignInfo = "#8be9fd",
	DiagnosticSignHint = "#50fa7b",
}) do
	vim.api.nvim_set_hl(0, name, { fg = color, bg = "none" })
end

-- 3) lspconfig + cmp capabilities
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local R = util.root_pattern

local ok_cmp, cmp_caps = pcall(require, "cmp_nvim_lsp")
local caps = vim.lsp.protocol.make_client_capabilities()
if ok_cmp then
	caps = cmp_caps.default_capabilities(caps)
end
caps.textDocument.completion.completionItem =
	vim.tbl_extend("force", caps.textDocument.completion.completionItem or {}, {
		documentationFormat = { "markdown", "plaintext" },
		snippetSupport = true,
		resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
	})

-- Hover window with border
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", max_width = 100 })

-- 3a) Diagnostics filter: Pyright, Ruff normalize, dedup, suppress noisy groovyls
local orig_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]

local DIAG_TAG_UNNECESSARY = (
	vim.lsp.protocol
	and vim.lsp.protocol.DiagnosticTag
	and vim.lsp.protocol.DiagnosticTag.Unnecessary
) or 1

local function is_unnecessary_tag(d)
	if not d or not d.tags then
		return false
	end
	for _, t in ipairs(d.tags) do
		if t == DIAG_TAG_UNNECESSARY then
			return true
		end
	end
	return false
end

local blocklist_codes = {
	reportUnusedImport = true,
	reportUnusedVariable = true,
	reportUnusedFunction = true,
	reportUnusedClass = true,
	reportDuplicateImport = true,
	reportUnusedExpression = true,
}

local function diag_key(d)
	if not d then
		return ""
	end
	local msg = (d.message or ""):gsub("%s+", " ")
	local sev = d.severity or 0
	if d.range and d.range.start and d.range["end"] then
		local s, e = d.range.start, d.range["end"]
		return string.format(
			"%d:%d:%d:%d:%d:%s",
			s.line,
			s.character,
			e.line or s.line,
			e.character or s.character,
			sev,
			msg
		)
	end
	return string.format("%d:%s", sev, msg)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	if result and result.diagnostics then
		local client = vim.lsp.get_client_by_id(ctx.client_id)
		local filtered, seen = {}, {}
		for _, d in ipairs(result.diagnostics) do
			if d.source and d.source:lower():match("^ruff") then
				d.source = "ruff"
			end

			-- Drop only false-positive groovyls "unable to resolve class" for Groovy stdlib
			if client and client.name == "groovyls" then
				local msg = d.message or ""
				if msg:match("unable to resolve class groovy%.transform%.") then
					goto continue
				end
			end

			if client and client.name == "pyright" then
				local code = d.code
				local code_str = (type(code) == "string") and code or ""
				local is_report = code_str:match("^report")
				local drop = not is_report or blocklist_codes[code_str] or is_unnecessary_tag(d)
				if drop then
					goto continue
				end
			end

			local key = diag_key(d)
			if not seen[key] then
				seen[key] = true
				table.insert(filtered, d)
			end
			::continue::
		end
		result.diagnostics = filtered
	end
	return orig_publish(err, result, ctx, config)
end

-- Common on_attach
local function on_attach(client, bufnr)
	map(bufnr, "n", "gd", vim.lsp.buf.definition)
	map(bufnr, "n", "gr", vim.lsp.buf.references)
	map(bufnr, "n", "gi", vim.lsp.buf.implementation)
	map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename)
	map(bufnr, { "n", "i" }, "<C-k>", vim.lsp.buf.signature_help)
	map(bufnr, "n", "K", vim.lsp.buf.hover)
	map(bufnr, "n", "gvd", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end)
	map(bufnr, "n", "gsd", function()
		vim.cmd("split")
		vim.lsp.buf.definition()
	end)
	if client.name == "ruff" then
		client.server_capabilities.hoverProvider = false
	end
end

-- Handy diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- code action
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })

-- ---- LSP Servers ----

-- Ansible-
lspconfig.ansiblels.setup({
	capabilities = caps,
	on_attach = on_attach,
	settings = {
		ansible = {
			ansible = { path = "ansible" },
			ansibleLint = {
				enabled = false,
				path = "ansible-lint",
			},
			executionEnvironment = { enabled = false },
			python = { interpreterPath = "python3" },

			-- 👇 disable the new-style validation linting
			validation = {
				enabled = true,
				lint = {
					enabled = false, -- 👈 turn off ansible-lint completely
					path = "ansible-lint",
				},
			},
		},
	},
})

-- Terraform LSP
lspconfig.terraformls.setup({
	capabilities = caps,
	on_attach = on_attach,
	filetypes = { "terraform" }, -- 👈 only *.tf, not tfvars
	root_dir = util.root_pattern(".terraform", ".git", "*.tf"),
})

-- Bash
lspconfig.bashls.setup({
	capabilities = caps,
	on_attach = on_attach,
	filetypes = { "sh", "bash" },
	root_dir = function(fname)
		return util.find_git_ancestor(fname) or (fname and util.path.dirname(fname)) or vim.loop.cwd()
	end,
})

-- Go
lspconfig.gopls.setup({
	capabilities = caps,
	on_attach = on_attach,
	root_dir = R("go.work", "go.mod", ".git"),
})

-- Lua
lspconfig.lua_ls.setup({
	capabilities = caps,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
	end,
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})

-- Python: Pyright
lspconfig.pyright.setup({
	capabilities = caps,
	on_attach = on_attach,
	root_dir = R("pyproject.toml", "uv.lock", "requirements.txt", ".git"),
	settings = { python = { analysis = { typeCheckingMode = "basic" } } },
})

-- Python: Ruff
lspconfig.ruff.setup({
	capabilities = caps,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		au("BufWritePre", {
			group = ag("ruff_fmt_" .. bufnr),
			buffer = bufnr,
			callback = function()
				if vim.bo[bufnr].filetype == "python" then
					buf_format_with("ruff")
				end
			end,
		})
	end,
})

-- TypeScript / JavaScript
lspconfig.ts_ls.setup({
	capabilities = caps,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	single_file_support = false,
	root_dir = R("tsconfig.json", "jsconfig.json", "package.json", ".git"),
})

-- ESLint
lspconfig.eslint.setup({
	capabilities = caps,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if c.name == "ts_ls" then
				c.server_capabilities.documentFormattingProvider = false
				c.server_capabilities.documentRangeFormattingProvider = false
			end
		end
		au("BufWritePre", {
			group = ag("eslint_fmt_" .. bufnr),
			buffer = bufnr,
			callback = function()
				local ft = vim.bo[bufnr].filetype
				if ft == "javascript" or ft == "javascriptreact" or ft == "typescript" or ft == "typescriptreact" then
					buf_format_with("eslint")
				end
			end,
		})
	end,
	root_dir = R(
		"eslint.config.js",
		"eslint.config.cjs",
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.json",
		"package.json",
		".git"
	),
	settings = {
		run = "onType",
		validate = "on",
		format = true,
		workingDirectory = { mode = "auto" },
		codeAction = {
			disableRuleComment = { enable = true, location = "separateLine" },
			showDocumentation = { enable = true },
		},
	},
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
		"svelte",
	},
})

lspconfig.yamlls.setup({
	capabilities = caps,
	on_attach = on_attach,
	filetypes = { "yaml" }, -- 👈 only plain YAML
})

-- Groovy
lspconfig.groovyls.setup({
	capabilities = caps,
	on_attach = on_attach,
	cmd = { vim.fn.expand("~/app/groovy-lsp/groovyls.sh") },
	filetypes = { "groovy" },
	root_dir = util.root_pattern("settings.gradle", "build.gradle", "mise.toml", ".git"),
})

-- JSON
lspconfig.jsonls.setup({
	capabilities = caps,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		-- Disable formatting if you want Conform/Prettier/etc. to handle it
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	settings = {
		json = {
			validate = { enable = true },
			schemas = require("schemastore").json.schemas(),
			schemaDownload = { enable = true },
		},
	},
})

-- JSON format on save (Conform handles it)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = ag("fmt_json"),
	pattern = { "*.json" },
	callback = function(args)
		pcall(function()
			require("conform").format({
				bufnr = args.buf,
				async = false,
				lsp_fallback = false,
			})
		end)
	end,
})

-- ---------- nvim-lint: YAML + Bash ----------
do
	local ok_lint, lint = pcall(require, "lint")
	if ok_lint then
		if type(lint.linters_by_ft) ~= "table" then
			lint.linters_by_ft = {}
		end

		lint.linters_by_ft.yaml = { "yamllint" }
		lint.linters_by_ft.sh = { "shellcheck", "shfmt_d" }
		lint.linters_by_ft.bash = { "shellcheck", "shfmt_d" }
		lint.linters_by_ft.terraform = { "tflint" }
		lint.linters_by_ft.tf = { "tflint" }

		-- Custom linter: shfmt -d
		lint.linters.shfmt_d = {
			cmd = "shfmt",
			stdin = true,
			args = { "-d", "-i", "4", "-ci", "-ln", "bash" },
			stream = "stdout",
			ignore_exitcode = true,
			parser = function(output, bufnr)
				local diags = {}
				if output ~= "" then
					table.insert(diags, {
						lnum = 0,
						col = 0,
						message = "File is not shfmt-formatted",
						severity = vim.diagnostic.severity.WARN,
						source = "shfmt",
					})
				end
				return diags
			end,
		}

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("lint_yaml_sh_bash", { clear = true }),
			pattern = { "*.yml", "*.yaml", "*.sh", "*.bash" },
			callback = function()
				pcall(lint.try_lint)
			end,
		})

		vim.api.nvim_create_user_command("LintNow", function()
			pcall(lint.try_lint)
		end, {})
	end
end

-- YAML format on save (Conform handles it)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = ag("fmt_yaml"),
	pattern = { "*.yml", "*.yaml" },
	callback = function(args)
		pcall(function()
			require("conform").format({ bufnr = args.buf, async = false, lsp_fallback = false })
		end)
	end,
})

-- Trim trailing whitespace
local function trim_trailing_ws(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local changed = false
	for i, line in ipairs(lines) do
		local new = line:gsub("%s+$", "")
		if new ~= line then
			lines[i] = new
			changed = true
		end
	end
	if changed then
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	end
end

-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	group = ag("trim_trailing_ws"),
-- 	pattern = { "*.py", "*.js", "*.jsx", "*.ts", "*.tsx", "Jenkinsfile" },
-- 	callback = function(args)
-- 		pcall(trim_trailing_ws, args.buf)
-- 	end,
-- })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = ag("trim_trailing_ws"),
	-- added *.json
	pattern = { "*.py", "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "Jenkinsfile" },
	callback = function(args)
		pcall(trim_trailing_ws, args.buf)
	end,
})

-- LSP-powered tag jumps
vim.o.tagfunc = "v:lua.vim.lsp.tagfunc"

-- Extra keymap: vsplit definition
vim.keymap.set("n", "<leader>vd", function()
	vim.cmd("vsplit")
	vim.lsp.buf.definition()
end, { desc = "LSP definition in vsplit" })
