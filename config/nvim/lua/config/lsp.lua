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

-- 2) Diagnostics (icons + highlights)
vim.diagnostic.config({
  virtual_lines = false,
  virtual_text  = true,
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.HINT]  = "•",  -- thin dot
      [vim.diagnostic.severity.INFO]  = "○",  -- open circle
      [vim.diagnostic.severity.WARN]  = "▲",  -- triangle
      [vim.diagnostic.severity.ERROR] = "✖",  -- small x
    },
  },
})

vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#ff5555", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticSignWarn",  { fg = "#ffb86c", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo",  { fg = "#8be9fd", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticSignHint",  { fg = "#50fa7b", bg = "none" })

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

-- Python: Pyright (types, diagnostics, defs, hover)
lspconfig.pyright.setup({
  capabilities = caps,
  on_attach = on_attach,
  root_dir = util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
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


-- Python: Ruff — format on save (LSP), optional CLI auto-fix after save
-- Tip: keep Pyright for types/hover; Jedi completion-only to avoid interference.
lspconfig.ruff.setup({
  capabilities = caps,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    client.server_capabilities.hoverProvider = false -- prefer Pyright hover

    -- 1) LSP formatting with Ruff on save (safe & stable)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if vim.bo[bufnr].filetype ~= "python" then return end
        -- format only with Ruff
        vim.lsp.buf.format({
          async = false,
          filter = function(c) return c.name == "ruff" end,
        })
      end,
    })

    -- 2) (Optional) CLI auto-fix after write: ruff --fix <file>
    --    Toggle at runtime: :let g:ruff_cli_fix = 1 (enable) / 0 (disable)
    if vim.g.ruff_cli_fix == nil then vim.g.ruff_cli_fix = 0 end
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = bufnr,
      callback = function()
        if vim.g.ruff_cli_fix ~= 1 then return end
        if vim.bo[bufnr].filetype ~= "python" then return end
        if vim.fn.executable("ruff") ~= 1 then return end

        local file = vim.api.nvim_buf_get_name(bufnr)
        if file == "" then return end

        -- remember mtime, run ruff --fix, reload buffer if changed
        local before = vim.uv.fs_stat(file)
        vim.system({ "ruff", "check", "--fix", "--exit-zero", file }, { text = true }, function()
          local after = vim.uv.fs_stat(file)
          if before and after and after.mtime.sec ~= before.mtime.sec then
            vim.schedule(function()
              -- reload silently if file changed on disk
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



lspconfig.rust_analyzer.setup({ capabilities = caps, on_attach = on_attach })

lspconfig.terraformls.setup({ capabilities = caps, on_attach = on_attach })

-- TypeScript / JavaScript (tsserver -> ts_ls)
lspconfig.ts_ls.setup({
  capabilities = caps,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
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

-- ESLint (diagnostics + code actions + formatting; live "onType")
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


    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        local ft = vim.bo[bufnr].filetype
        if ft == "javascript" or ft == "javascriptreact"
          or ft == "typescript" or ft == "typescriptreact"
        then
          vim.lsp.buf.format({
            async = false,
            filter = function(c) return c.name == "eslint" end,
          })
        end
      end,
    })
  end,
  root_dir = util.root_pattern(
    "eslint.config.js", "eslint.config.cjs",
    ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
    "package.json", ".git"
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
    "javascript", "javascriptreact", "javascript.jsx",
    "typescript", "typescriptreact", "typescript.tsx",
    "vue", "svelte",
  },
})

lspconfig.yamlls.setup({ capabilities = caps, on_attach = on_attach })


-- Trim trailing whitespace on save for Python files
vim.api.nvim_create_autocmd("BufWritePre", {
   pattern = { "*.py", "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[:keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})
