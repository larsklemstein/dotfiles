-- ~/.config/nvim/lua/config/lsp/on_attach.lua

local function on_attach(client, bufnr)
    local bufmap = function(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
    end

    bufmap("n", "gd", vim.lsp.buf.definition)
    bufmap("n", "gr", vim.lsp.buf.references)
    bufmap("n", "K", vim.lsp.buf.hover)
    bufmap("n", "<leader>rn", vim.lsp.buf.rename)
    bufmap("n", "<leader>ca", vim.lsp.buf.code_action)

    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ async = false })
            end,
        })
    end
end

return on_attach
