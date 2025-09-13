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
  if vim.lsp and vim.lsp.completion and vim.lsp.completion.enable then
    vim.lsp.completion.enable(false)
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        vim.lsp.completion.enable(false, args.buf)
        -- keep local completeopt sane even if a ftplugin touches it
        vim.schedule(function()
          vim.opt_local.completeopt = { "menu", "menuone", "noselect" }
        end)
      end,
    })
  end
end)

-- 2) Diagnostics (your icons & prefs)
vim.diagnostic.config({
  virtual_lines = false,
  virtual_text  = true,
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.HINT] = '👉',
      [vim.diagnostic.severity.WARN] = '⚠️',
      [vim.diagnostic.severity.INFO] = 'ℹ️',
      [vim.diagnostic.severity.ERROR] = '❌',
    },
  },
})

-- 3) LSP servers via lspconfig + cmp capabilities
local lspconfig = require("lspconfig")
local util      = require("lspconfig.util")

-- Ask for rich completion payloads; merge cmp capabilities
local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
}
caps = require("cmp_nvim_lsp").default_capabilities(caps)

-- Common on_attach (keymaps, tweaks per client)
local on_attach = function(client, bufnr)
  local map = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true }) end
  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "K",  vim.lsp.buf.hover)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help)

  -- Prefer Pyright hover over Ruff hover
  if client.name == "ruff" then
    client.server_capabilities.hoverProvider = false
  end

  -- Let **Jedi** provide completion (docstrings in completion items),
  -- keep **Pyright** for types/diagnostics/defs/hover.
  if client.name == "pyright" then
    client.server_capabilities.completionProvider = nil
  end
  if client.name == "jedi_language_server" then
    -- We rely on Pyright for diagnostics and hover to avoid double messages.
    client.server_capabilities.hoverProvider = false
    -- (Diagnostics already disabled in init_options below)
  end
end

-- 4) Server setups

lspconfig.bashls.setup({ capabilities = caps, on_attach = on_attach })

lspconfig.gopls.setup({
  capabilities = caps,
  on_attach = on_attach,
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
})

lspconfig.groovyls.setup({ capabilities = caps, on_attach = on_attach })

lspconfig.lua_ls.setup({
  capabilities = caps,
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

-- Pyright: types, diagnostics, go-to, hover (NO completion)
lspconfig.pyright.setup({
  capabilities = caps,
  on_attach = on_attach,
  root_dir = util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
  settings = {
    python = {
      analysis = {
        useLibraryCodeForTypes = true,
        autoImportCompletions = true,
        typeCheckingMode = "basic",     -- or "strict"
        diagnosticMode = "workspace",
        indexing = true,                -- safe if supported; ignored otherwise
      },
    },
  },
})

-- Jedi LS: completions with docstrings (diagnostics off)
lspconfig.jedi_language_server.setup({
  capabilities = caps,
  on_attach = on_attach,
  root_dir = util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
  init_options = {
    completion = { disableSnippets = false },
    diagnostics = { enable = false },   -- avoid overlap; Pyright handles diagnostics
  },
})

lspconfig.rust_analyzer.setup({ capabilities = caps, on_attach = on_attach })

lspconfig.terraformls.setup({ capabilities = caps, on_attach = on_attach })

-- TypeScript / JavaScript (new name is ts_ls; tsserver is deprecated)
lspconfig.ts_ls.setup({
  capabilities = caps,
  on_attach = on_attach,
  single_file_support = false,
  root_dir = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
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

lspconfig.yamlls.setup({ capabilities = caps, on_attach = on_attach })
