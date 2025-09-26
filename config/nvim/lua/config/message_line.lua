-- Keep cmdheight=1 always (no jumping)
vim.opt.cmdheight = 1

-- Save original handler
if not vim.g._orig_cmdline then
    vim.g._orig_cmdline = vim.api.nvim_get_option_value
end

-- Function to clear the cmdline (without hiding it)
local function clear_cmdline()
    vim.cmd("echo ''")
end

-- On insert, blank out messages
vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
        -- clear whatever is currently shown
        clear_cmdline()
        -- set up an autocmd to clear again if something gets echoed
        vim.api.nvim_create_augroup("InsertCmdlineClear", { clear = true })
        vim.api.nvim_create_autocmd("CmdlineChanged", {
            group = "InsertCmdlineClear",
            callback = clear_cmdline,
        })
        vim.api.nvim_create_autocmd("CmdlineLeave", {
            group = "InsertCmdlineClear",
            callback = clear_cmdline,
        })
    end,
})

-- On leaving insert, allow messages again
vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        vim.api.nvim_del_augroup_by_name("InsertCmdlineClear")
    end,
})

-- ~/.config/nvim/lua/config/lsp/setup.lua  (or a separate diagnostics.lua)
vim.diagnostic.config({
    update_in_insert = false, -- don’t show diagnostics while typing in insert-mode
    underline = true,
    virtual_text = {
        spacing = 2,
        prefix = "●",
    },
    float = {
        border = "rounded",
    },
})

-- add a debounce so diagnostics refresh only after 500 ms of no typing
for _, client in ipairs(vim.lsp.get_clients()) do
    if client.server_capabilities then
        client.config.flags = client.config.flags or {}
        client.config.flags.debounce_text_changes = 250 -- milliseconds
    end
end
