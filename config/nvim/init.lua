------------------------------------------------------------
-- Basic Options
------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 5
vim.opt.cursorline = true                 -- highlight current line

------------------------------------------------------------
-- Leader + basic keymaps
------------------------------------------------------------
vim.g.mapleader = " "
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>", { desc = "Write" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

------------------------------------------------------------
-- Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({

  -- Telescope + dependency
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      local map = vim.keymap.set
      map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
      map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",  { desc = "Grep text" })
      map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",    { desc = "List buffers" })
      map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",  { desc = "Help tags" })
    end,
  },

  -- Seamless tmux-pane navigation
  { "christoomey/vim-tmux-navigator" },

  -- Lualine status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",      -- picks colors from active colorscheme
          icons_enabled = true,
          section_separators = "",
          component_separators = "|",
        },
      })
    end,
  },

  -- Vague colorscheme
  {
    "vague2k/vague.nvim",
    config = function()
      require("vague").setup({
        transparent = false,
      })
      local ok = pcall(vim.cmd, "colorscheme vague")
      if not ok then
        vim.cmd.colorscheme("habamax")
      end
    end,
  },
})

------------------------------------------------------------
-- Fallback for first boot: use habamax if vague not installed yet
------------------------------------------------------------
if not pcall(vim.cmd, "colorscheme vague") then
  vim.cmd.colorscheme("habamax")
end
