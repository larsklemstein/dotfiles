-- ~/.config/nvim/lua/config/lsp/diagnostics.lua
local timer = nil

-- Save the original handler
local orig_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

-- Replace it with a debounced version
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    if timer then
        timer:stop()
        timer:close()
    end
    timer = vim.defer_fn(function()
        orig_handler(err, result, ctx, config)
    end, 500) -- delay in ms
end

-- Optional: do not update while typing in insert mode
vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = { spacing = 2, prefix = "●" },
})
