require("gitsigns").setup({
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
        use_focus = true,
    },

    -- Hide blame when the current line has ANY diagnostics
    -- NOTE: current_line_blame_formatter may be a FUNCTION.
    -- The function’s return is passed directly to `virt_text` (a list of chunks).
    -- Returning `{}` draws nothing → no blame shown.
    current_line_blame_formatter = function(_, blame)
        local bufnr = vim.api.nvim_get_current_buf()
        local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
        if #vim.diagnostic.get(bufnr, { lnum = lnum }) > 0 then
            return {} -- suppress blame text on diagnostic lines
        end
        if blame.author == "Not Committed Yet" then
            return {} -- (optional) also hide for uncommitted lines
        end
        local text =
            string.format("%s • %s • %s", blame.author, os.date("%Y-%m-%d", blame.author_time), blame.summary or "")
        return { { " " .. text, "GitSignsCurrentLineBlame" } }
    end,
})
