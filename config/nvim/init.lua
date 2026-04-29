------------------------------------------------------------
-- Minimal, deterministic, lazy-optimized Neovim setup
------------------------------------------------------------

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.g.mapleader = " "

------------------------------------------------------------
-- lazy.nvim bootstrap
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({

------------------------------------------------------------
-- Colorscheme (einziger Early-Load)
------------------------------------------------------------
{
  "sainnhe/everforest",
  lazy = false,
  priority = 1000,
  init = function()
    vim.g.everforest_background = "hard"
  end,
  config = function()
    vim.cmd.colorscheme("everforest")
  end,
},

------------------------------------------------------------
-- Indent guides (lazy)
------------------------------------------------------------
{
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = "VeryLazy",
  dependencies = { "TheGLander/indent-rainbowline.nvim" },
  config = function()
    local hooks = require("ibl.hooks")

    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0,"RainbowBlue",{fg="#3f5f7f",blend=45})
      vim.api.nvim_set_hl(0,"RainbowGreen",{fg="#4f6f4f",blend=45})
      vim.api.nvim_set_hl(0,"RainbowYellow",{fg="#7f6f3f",blend=45})
      vim.api.nvim_set_hl(0,"RainbowViolet",{fg="#6f5f7f",blend=45})
    end)

    require("ibl").setup({
      indent = {
        char = "▏",
        highlight = {
          "RainbowBlue","RainbowGreen","RainbowYellow","RainbowViolet"
        },
      },
      scope = { enabled = false },
      whitespace = { remove_blankline_trail = true },
    })
  end,
},

------------------------------------------------------------
-- OSC52 (lazy)
------------------------------------------------------------
{
  "ojroques/nvim-osc52",
  event = "VeryLazy",
  config = function()
    if vim.env.SSH_CONNECTION then
      require("osc52").setup({ max_length = 0, silent = true })
    end
  end,
},

------------------------------------------------------------
-- Neo-tree
------------------------------------------------------------
{
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("neo-tree").setup({
      default_component_configs = {
        icon = { enabled = false },
      },
      filesystem = {
        filtered_items = { hide_dotfiles = true },
        follow_current_file = { enabled = true },
      },
    })
  end,
},

------------------------------------------------------------
-- Telescope
------------------------------------------------------------
{
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = { "nvim-lua/plenary.nvim" },
},

------------------------------------------------------------
-- Treesitter
------------------------------------------------------------
{
  "nvim-treesitter/nvim-treesitter",
  event = "BufReadPost",
  build = ":TSUpdate",
},

------------------------------------------------------------
-- Completion
------------------------------------------------------------
{
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },
},

------------------------------------------------------------
-- Mason
------------------------------------------------------------
{
  "williamboman/mason.nvim",
  cmd = "Mason",
  config = function()
    require("mason").setup()
  end,
},

------------------------------------------------------------
-- tmux navigator
------------------------------------------------------------
{
  "christoomey/vim-tmux-navigator",
  event = "VeryLazy",
},

------------------------------------------------------------
-- Lualine (lazy)
------------------------------------------------------------
{
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        section_separators = "",
        component_separators = "",
      },
    })
  end,
},

------------------------------------------------------------
-- GITSIGNS (FIX)
------------------------------------------------------------
{
  "lewis6991/gitsigns.nvim",
  event = "VeryLazy",
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
    },
  },
},

})

------------------------------------------------------------
-- gitsigns attach (non-blocking, deterministic)
------------------------------------------------------------
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local dir = vim.fn.fnamemodify(args.file, ":p:h")
    if vim.fn.finddir(".git", dir .. ";") ~= "" then
      require("gitsigns").attach()
    end
  end,
})

------------------------------------------------------------
-- Basics
------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.autoread = true
