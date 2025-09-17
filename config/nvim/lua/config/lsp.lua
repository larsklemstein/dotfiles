-- ~/.config/nvim/lua/config/lsp.lua

-- 1) Let cmp own completion UI (no builtin popup/fuzzy/preview)
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")
vim.cmd([[
  set completeopt-=preview
  set completeopt-=popup
  set completeopt-=fuzzy
]])

-- Neovim 0.11 native LSP completion: force OFF (global + per buffer)
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

-- Small helpers
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

-- 2) Diagnostics (icons + highlights)
vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = true,
	update_in_insert = false,
	signs = {
		text = {
			[vim.diagnostic.severity.HINT] = "•",
			[vim.diagnostic.severity.INFO] = "○",
			[vim.diagnostic.severity.WARN] = "▲",
			[vim.diagnostic.severity.ERROR] = "✖",
		},
	},
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

-- Common on_attach (keymaps, tweaks per client)
local function on_attach(client, bufnr)
	map(bufnr, "n", "gd", vim.lsp.buf.definition)
	map(bufnr, "n", "gr", vim.lsp.buf.references)
	map(bufnr, "n", "gi", vim.lsp.buf.implementation)
	map(bufnr, "n", "K", vim.lsp.buf.hover)
	map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename)
	map(bufnr, { "n", "i" }, "<C-k>", vim.lsp.buf.signature_help)

	-- Prefer Pyright hover over Ruff hover
	if client.name == "ruff" then
		client.server_capabilities.hoverProvider = false
	end
end

-- 4) Server setups (simple ones first)
for _, srv in ipairs({ "groovyls", "rust_analyzer", "terraformls", "yamlls" }) do
	if lspconfig[srv] then
		lspconfig[srv].setup({ capabilities = caps, on_attach = on_attach })
	end
end

-- Bash
lspconfig.bashls.setup({
	capabilities = caps,
	on_attach = on_attach,
	-- cover both ft=sh and ft=bash
	filetypes = { "sh", "bash" },
	-- start in git root, file dir, or fall back to CWD (works for unsaved buffers)
	root_dir = function(fname)
		return util.find_git_ancestor(fname) or (fname and util.path.dirname(fname)) or vim.loop.cwd()
	end,
	-- optional: make diagnostics stronger if shellcheck is installed
	settings = {
		bashIde = {
			-- globPattern = "**/*@(.sh|.bash)"  -- you can set this if desired
		},
	},
})

-- Go
lspconfig.gopls.setup({
	capabilities = caps,
	on_attach = on_attach,
	root_dir = R("go.work", "go.mod", ".git"),
})

-- Lua (disable LSP formatting to avoid fighting StyLua)
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

-- Python: Pyright (types/hover/defs/diagnostics)
lspconfig.pyright.setup({
	capabilities = caps,
	on_attach = on_attach,
	root_dir = R("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
	settings = {
		python = {
			analysis = {
				useLibraryCodeForTypes = true,
				autoImportCompletions = true,
				typeCheckingMode = "basic",
				diagnosticMode = "workspace",
				indexing = true,
			},
		},
	},
})

-- Python: Ruff — format on save (LSP) + optional CLI fix
lspconfig.ruff.setup({
	capabilities = caps,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		client.server_capabilities.hoverProvider = false -- prefer Pyright hover

		-- LSP formatting (Ruff) on save
		au("BufWritePre", {
			group = ag("ruff_fmt_" .. bufnr),
			buffer = bufnr,
			callback = function()
				if vim.bo[bufnr].filetype == "python" then
					buf_format_with("ruff")
				end
			end,
		})

		-- Optional: ruff CLI auto-fix right after write (toggle with :let g:ruff_cli_fix=1)
		if vim.g.ruff_cli_fix == nil then
			vim.g.ruff_cli_fix = 0
		end
		au("BufWritePost", {
			group = ag("ruff_cli_" .. bufnr),
			buffer = bufnr,
			callback = function()
				if vim.g.ruff_cli_fix ~= 1 or vim.bo[bufnr].filetype ~= "python" then
					return
				end
				if vim.fn.executable("ruff") ~= 1 then
					return
				end
				local file = vim.api.nvim_buf_get_name(bufnr)
				if file == "" then
					return
				end
				local before = vim.uv.fs_stat(file)
				vim.system({ "ruff", "check", "--fix", "--exit-zero", file }, { text = true }, function()
					local after = vim.uv.fs_stat(file)
					if before and after and after.mtime.sec ~= before.mtime.sec then
						vim.schedule(function()
							local curpos = vim.api.nvim_win_get_cursor(0)
							vim.cmd("checktime " .. bufnr)
							pcall(vim.cmd, "e!")
							pcall(vim.api.nvim_win_set_cursor, 0, curpos)
						end)
					end
				end)
			end,
		})
	end,
})

-- TypeScript / JavaScript (tsserver -> ts_ls)
lspconfig.ts_ls.setup({
	capabilities = caps,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		-- Always let ESLint own formatting
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	single_file_support = false,
	root_dir = R("tsconfig.json", "jsconfig.json", "package.json", ".git"),
	init_options = {
		hostInfo = "neovim",
		preferences = {
			includeCompletionsForModuleExports = true,
			includeCompletionsWithSnippetText = true,
			includeAutomaticOptionalChainCompletions = true,
			includeCompletionsWithObjectLiteralMethodSnippets = true,
		},
	},
})

-- ESLint (diagnostics + code actions + formatting on save)
lspconfig.eslint.setup({
	capabilities = caps,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)

		-- Ensure ts_ls formatting stays off (Neovim 0.12-safe API)
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if c.name == "ts_ls" then
				c.server_capabilities.documentFormattingProvider = false
				c.server_capabilities.documentRangeFormattingProvider = false
			end
		end

		-- Format JS/TS with ESLint on save
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
		nodePath = nil,
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

-- 5) Lua formatting via StyLua (Option A with conform.nvim)
do
	local ok, conform = pcall(require, "conform")
	if ok then
		-- Configure Stylua for Lua (merge-friendly if you configure conform elsewhere)
		local existing = conform.formatters_by_ft or {}
		conform.setup({
			notify_on_error = true,
			formatters_by_ft = vim.tbl_deep_extend("force", existing, {
				lua = { "stylua" },
			}),
		})

		-- Format Lua on save (blocking, like your Ruff/ESLint setup)
		au("BufWritePre", {
			group = ag("fmt_lua_stylua"),
			pattern = "*.lua",
			callback = function(args)
				conform.format({ bufnr = args.buf, async = false, lsp_fallback = false })
			end,
		})
	end
end

-- 6) Editor niceties: trim trailing whitespace on save (non-Lua)
au("BufWritePre", {
	group = ag("trim_trailing_ws"),
	pattern = { "*.py", "*.js", "*.jsx", "*.ts", "*.tsx" },
	callback = function()
		local view = vim.fn.winsaveview()
		vim.cmd([[:keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})

-- Use LSP for tag-style jumps: Ctrl-] to go to definition, Ctrl-t to jump back
vim.o.tagfunc = "v:lua.vim.lsp.tagfunc"

-- Open definition in a vertical split
vim.keymap.set("n", "<leader>vd", function()
	vim.cmd("vsplit")
	vim.lsp.buf.definition()
end, { desc = "LSP definition in vsplit" })
