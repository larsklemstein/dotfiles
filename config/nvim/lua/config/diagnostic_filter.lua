-- ~/.config/nvim/lua/config/lsp/diagnostic_filter.lua

local orig_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    if not result or not result.diagnostics then
        return orig_handler(err, result, ctx, config)
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
        return orig_handler(err, result, ctx, config)
    end

    local bufnr = vim.uri_to_bufnr(result.uri)

    -- Ruff filter
    if client.name == "ruff" or client.name == "Ruff" then
        vim.notify("Ruff published " .. #result.diagnostics .. " diagnostics", vim.log.levels.INFO)

        local taken = {}
        for _, pd in ipairs(vim.diagnostic.get(bufnr)) do
            if pd.source == "Pyright" then
                taken[pd.lnum .. ":" .. pd.col] = true
            end
        end

        local before = #result.diagnostics
        result.diagnostics = vim.tbl_filter(function(d)
            if d.code == "E999" or d.code == "F821" then
                vim.notify("Dropping Ruff " .. d.code .. " at line " .. d.lnum, vim.log.levels.WARN)
                return false
            end
            if taken[d.lnum .. ":" .. d.col] then
                vim.notify("Dropping Ruff duplicate at line " .. d.lnum, vim.log.levels.WARN)
                return false
            end
            return true
        end, result.diagnostics)
        local after = #result.diagnostics
        vim.notify("Ruff kept " .. after .. " / " .. before .. " diagnostics", vim.log.levels.INFO)
    end

    return orig_handler(err, result, ctx, config)
end
