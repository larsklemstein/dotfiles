-- 6) load lint config after startup (avoids blocking UI)
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("cfg_lint", { clear = true }),
    callback = function()
        require("config.lint")
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("fmt_go_on_save", { clear = true }),
    pattern = "*.go",
    callback = function()
        pcall(vim.lsp.buf.format, { async = false })
    end,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.yml", "*.yaml" },
    callback = function(args)
        local f = args.file
        if f:match("playbook") or f:match("roles/.*/tasks/") or f:match("roles/.*/handlers/") then
            vim.bo.filetype = "yaml.ansible"
        end
    end,
})

-- Go: use 4 spaces instead of default 8
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    group = vim.api.nvim_create_augroup("go_tab_settings", { clear = true }),
    callback = function()
        vim.bo.tabstop = 4 -- how many spaces a <Tab> counts for
        vim.bo.shiftwidth = 4 -- spaces for autoindent
        vim.bo.expandtab = false -- keep tabs as real tabs (common in Go projects)
    end,
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
