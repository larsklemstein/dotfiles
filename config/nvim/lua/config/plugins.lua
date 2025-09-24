-- ~/.config/nvim/lua/plugins.lua

local Plug = vim.fn["plug#"]

vim.call("plug#begin")

-- Core LSP
Plug("neovim/nvim-lspconfig")

-- Treesitter
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" })
Plug("nvim-treesitter/nvim-treesitter-textobjects")

-- Lua utility lib (required by several plugins)
Plug("nvim-lua/plenary.nvim")

-- Telescope (lazy on :Telescope)
Plug("nvim-telescope/telescope.nvim")

-- Optional: native FZF accel for Telescope (lazy on :Telescope)
Plug("nvim-telescope/telescope-fzf-native.nvim", { ["do"] = "make", ["on"] = "Telescope" })

-- File tree (lazy on :NvimTreeToggle) + icons
Plug("nvim-tree/nvim-tree.lua", { ["on"] = "NvimTreeToggle" })
Plug("nvim-tree/nvim-web-devicons") -- optional icons

-- Formatting (e.g. StyLua via conform)
Plug("stevearc/conform.nvim")

-- Git signs (always-on; vim-plug can’t lazy by event)
Plug("lewis6991/gitsigns.nvim")

-- Statusline
Plug("nvim-lualine/lualine.nvim")

-- Comments
Plug("tpope/vim-commentary")

-- Linting (YAML only; configured below)
Plug("mfussenegger/nvim-lint")

-- LazyGit (lazy on :LazyGit)
Plug("kdheepak/lazygit.nvim", { ["on"] = "LazyGit" })

Plug("dhruvasagar/vim-table-mode")

-- Completion + snippets
Plug("hrsh7th/nvim-cmp")
Plug("hrsh7th/cmp-nvim-lsp")
Plug("hrsh7th/cmp-path")
Plug("hrsh7th/cmp-buffer") -- optional
Plug("hrsh7th/cmp-cmdline") -- optional
Plug("L3MON4D3/LuaSnip")
Plug("saadparwaiz1/cmp_luasnip")
Plug("rafamadriz/friendly-snippets")
Plug("hrsh7th/cmp-nvim-lsp-signature-help") -- optional

Plug("b0o/SchemaStore.nvim")
-- Motions (optional)
-- Plug("folke/flash.nvim")

-- Theme
Plug("vague2k/vague.nvim")

vim.call("plug#end")
