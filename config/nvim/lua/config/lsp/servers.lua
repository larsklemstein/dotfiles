-- ~/.config/nvim/lua/config/lsp/servers.lua

local servers = {
    bashls = {},
    terraformls = {},
    rust_analyzer = {
        settings = {
            ["rust-analyzer"] = {
                cargo = { allFeatures = true },
                checkOnSave = { command = "clippy" },
            },
        },
    },
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { checkThirdParty = false },
            },
        },
    },
    yamlls = {
        settings = {
            yaml = { keyOrdering = false },
        },
    },
    jsonls = {},
    html = {},
    ts_ls = {},
    pyright = {},
    -- in ~/.config/nvim/lua/config/lsp/servers.lua
    ruff = {
        init_options = {
            args = { "--line-length=78" },
        },
        -- ❗ Disable Ruff’s built-in diagnostics so Pyright is the only source
        settings = {
            diagnostics = { enable = false }, -- first option to try
            -- lint = { run = "never" },         -- if the line above doesn’t work, try this instead
        },
    },
    gopls = {},
    dockerls = {},
    docker_compose_language_service = {},
    groovyls = {},
    perlnavigator = {},
    clojure_lsp = {},
    helm_ls = {},
    jinja_lsp = {},
    eslint = {},
}

return servers
