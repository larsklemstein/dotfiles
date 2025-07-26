return {
    -- command and argument sto start the language server for Lua
    cmd = { "lua-language-server" },

    filetypes = { "lua" },

    root_markers = { {"lua-project.json", "lua-project.yaml", "lua-project.yml" }, '.git' },

    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },

            diagnostics = {
                globals = { 'vim' },  -- Recognize 'vim' as a global variable
            },
        },
    },
}

