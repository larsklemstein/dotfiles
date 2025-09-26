-- ~/.config/nvim/lua/config/lsp/setup.lua
-- Using the current stable nvim-lspconfig API
-- (ignore the deprecation warning for now)

local lspconfig = require("lspconfig") -- ✅ old, stable entry-point
local servers = require("config.lsp.servers")
local capabilities = require("config.lsp.capabilities")
local on_attach = require("config.lsp.on_attach")

for name, cfg in pairs(servers) do
	if lspconfig[name] then
		-- inject shared opts
		cfg.capabilities = capabilities
		cfg.on_attach = on_attach

		lspconfig[name].setup(cfg) -- ✅ stable setup call
	else
		vim.notify("LSP server not found in lspconfig: " .. name, vim.log.levels.WARN)
	end
end

-- Global diagnostic display configuration
vim.diagnostic.config({
	update_in_insert = false,
	virtual_text = { spacing = 2, prefix = "●" },
	float = { border = "rounded" },
})
