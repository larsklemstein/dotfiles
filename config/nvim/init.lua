------------------------------------------------------------
-- Minimal, safe Neovim setup (v0.1.16)
-- LSP-free, deterministic, ergonomic
------------------------------------------------------------

vim.opt.expandtab = true      -- convert Tab -> spaces
vim.opt.shiftwidth = 4        -- indent size
vim.opt.tabstop = 4           -- display width of Tab
vim.opt.softtabstop = 4       -- editing width of Tab

------------------------------------------------------------
-- 0. Leader key
------------------------------------------------------------
vim.g.mapleader = " "

------------------------------------------------------------
-- 1. Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- 2. Plugins
------------------------------------------------------------
require("lazy").setup({
  ------------------------------------------------------------
  -- Minimal Colorschemes (choose ONE)
  ------------------------------------------------------------
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    enabled = false,
    config = function()
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    enabled = false,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  {
    "ojroques/nvim-osc52",
  },

  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    enabled = true,
    config = function()
      vim.g.everforest_background = "hard"
      vim.cmd.colorscheme("everforest")
    end,
  },

  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    enabled = false,
    config = function()
      require("onedark").setup({ style = "dark" })
      require("onedark").load()
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    enabled = false,
    opts = { integrations = {} },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
  },
  config = function()
    require("neo-tree").setup({
      default_component_configs = {
        icon = { enabled = false },  -- disables icon component
      },

      -- REMOVE ALL ICON COMPONENTS FROM RENDERERS
      renderers = {
        directory = {
          -- no icon here
          { "name" },
        },
        file = {
          -- no icon here
          { "name" },
        },
        message = {
          { "name" },
        },
      },

      filesystem = {
        filtered_items = { hide_dotfiles = true },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },

      window = { width = 30 },
    })
  end,
},


  ------------------------------------------------------------
  -- Telescope (lazy)
  ------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end,    desc = "Buffers" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end,   desc = "Recent files" },
      { "<leader>fs", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Search in buffer" },
    },
  },

  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

{
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      completion = {
        autocomplete = false,  -- no popup while typing, only on <C-Space>
      },
      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-e>"] = cmp.mapping.close(),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
      },
      sources = {
        { name = "path" },
        { name = "buffer" },
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    })
  end,
},

{
  "williamboman/mason.nvim",
  cmd = "Mason",
  config = function()
    require("mason").setup()
  end,
},


  { "christoomey/vim-tmux-navigator" },

  ------------------------------------------------------------
  -- Lualine (neutral theme)
  ------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = "",
          component_separators = "",
          icons_enabled = true,
        },
      })
    end,
  },

  ------------------------------------------------------------
  -- Git integrations
  ------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = { add = { text = "│" }, change = { text = "│" }, delete = { text = "_" } },
      on_attach = function(buf)
        local gs = package.loaded.gitsigns
        local map = function(l, r, d)
          vim.keymap.set("n", l, r, { buffer = buf, desc = d })
        end
        map("]h", gs.next_hunk, "Next hunk")
        map("[h", gs.prev_hunk, "Prev hunk")
        map("<leader>hp", gs.preview_hunk, "Preview hunk")
        map("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  {
    "f-person/git-blame.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      delay = 500,
      message_template = "<author>, <date> • <summary>",
      date_format = "%Y-%m-%d",
    },
    config = function(_, opts)
      require("gitblame").setup(opts)
      vim.keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>", { desc = "Toggle blame" })
    end,
  },

})

------------------------------------------------------------
-- 5. NvimTree flash highlight
------------------------------------------------------------
vim.api.nvim_set_hl(0, "NvimTreeFindCursorLine",
  { bg = "#fabd2f", fg = "#1d2021", bold = true })


------------------------------------------------------------
-- 6. Bottom terminal toggle
------------------------------------------------------------
local term_buf, term_win = nil, nil
local TERMINAL_HEIGHT_RATIO = 0.35

local function toggle_bottom_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    return
  end

  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
    term_buf = vim.api.nvim_create_buf(false, true)
  end

  local height = math.floor(vim.o.lines * TERMINAL_HEIGHT_RATIO)
  vim.cmd("botright " .. height .. "split")
  term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(term_win, term_buf)

  if vim.bo[term_buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell, { cwd = vim.fn.getcwd() })
  end

  vim.bo[term_buf].buflisted = false
  vim.bo[term_buf].filetype = "terminal"
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>tb", toggle_bottom_terminal, { noremap = true, silent = true })
vim.keymap.set("t", "<leader>tb", toggle_bottom_terminal, { noremap = true, silent = true })

-- terminal in current file dir
vim.keymap.set("n", "<leader>tf", function()
  local file_dir = vim.fn.expand("%:p:h")
  if file_dir == "" then file_dir = vim.fn.getcwd() end

  vim.cmd("botright split")
  vim.cmd("resize 15")
  vim.cmd("terminal")

  vim.fn.chansend(vim.b.terminal_job_id, "cd " .. file_dir .. "\n")
  vim.cmd("startinsert")
end, { desc = "Open terminal in current file directory" })

------------------------------------------------------------
-- 7. Yank helpers for terminal
------------------------------------------------------------
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ty", function()
  vim.cmd('normal! ggVG"+y')
  print("Terminal output yanked to system clipboard (+)")
end, { noremap = true, silent = true })

------------------------------------------------------------
-- 8. Async format-on-save (uv-safe)
------------------------------------------------------------
local formatters = {
  lua     = { cmd = { "stylua", "--respect-ignores" }, config_files = { ".stylua.toml", "stylua.toml" } },
  python  = { cmd = { "ruff", "format" }, config_files = { "pyproject.toml", "ruff.toml" } },
  javascript = { cmd = { "prettier", "--write" }, config_files = { ".prettierrc", "prettier.config.js" } },
  typescript = { cmd = { "prettier", "--write" }, config_files = { ".prettierrc", "prettier.config.js" } },
  go      = { cmd = { "gofmt", "-w" }, config_files = { "go.mod" } },
  rust    = { cmd = { "rustfmt" }, config_files = { "rustfmt.toml", ".rustfmt.toml" } },
}

local function get_project_root()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  return (root and root ~= "") and root or vim.fn.getcwd()
end

local function project_has_config(files)
  local root = get_project_root()
  for _, f in ipairs(files) do
    if vim.loop.fs_stat(root .. "/" .. f) then return true end
  end
  return false
end

local function run_formatter_async(filepath, fmt)
  local args = vim.deepcopy(fmt.cmd)
  table.insert(args, filepath)

  local handle
  handle = vim.loop.spawn(args[1], { args = vim.list_slice(args, 2) }, function(code, _)
    if handle and not handle:is_closing() then
      handle:close()
    end

    vim.schedule(function()
      if code ~= 0 then
        vim.notify("[format] " .. args[1] .. " exited with code " .. code, vim.log.levels.WARN)
        return
      end

      local bufnr = vim.fn.bufnr(filepath)
      if bufnr >= 0 and vim.api.nvim_buf_is_loaded(bufnr) then
        local win = vim.fn.bufwinid(bufnr)
        if win ~= -1 and vim.api.nvim_win_is_valid(win) then
          local ok, curpos = pcall(vim.api.nvim_win_get_cursor, win)
          vim.cmd("checktime " .. bufnr)
          if ok then pcall(vim.api.nvim_win_set_cursor, win, curpos) end
        else
          vim.cmd("checktime " .. bufnr)
        end
      end
    end)
  end)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local fmt = formatters[ft]
    if not fmt then return end
    if vim.fn.executable(fmt.cmd[1]) == 0 then return end
    if not project_has_config(fmt.config_files) then return end

    local filepath = vim.api.nvim_buf_get_name(args.buf)
    if filepath == "" then return end

    run_formatter_async(filepath, fmt)
  end,
})

------------------------------------------------------------
-- 9. Filetype & syntax detection
------------------------------------------------------------
vim.cmd([[
  filetype on
  filetype plugin indent on
  syntax on
]])

vim.api.nvim_create_autocmd({ "BufNewFile", "TextChanged", "TextChangedI", "BufWritePost" }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "" or vim.bo.filetype == "text" then
      vim.cmd("filetype detect")
    end
  end,
})

------------------------------------------------------------
-- 10. Extra keymaps
------------------------------------------------------------
vim.keymap.set("n", "<leader>rf", function()
  vim.cmd("read " .. vim.fn.expand("<cfile>"))
end, { desc = "Insert contents of file under cursor" })

vim.keymap.set("n", "<leader>hh", function()
  require("nvim-tree.api").tree.toggle_hidden_filter()
end, { desc = "nvim-tree: Toggle dotfiles" })

vim.keymap.set("n", "<leader>qq", "<cmd>qa<CR>", { noremap = true, silent = true, desc = "Quit all" })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[silent! %s/\%xa0/ /ge]],
})

vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.backupcopy = "yes"
vim.opt.autoread = true

vim.keymap.set('n', '<C-c>', ':nohl<CR>',
  { noremap = true, silent = true, desc = 'Clear search highlight' })

vim.keymap.set('c', '<C-A>', '<Home>', { noremap = true })
vim.keymap.set('c', '<C-E>', '<End>',  { noremap = true })
vim.keymap.set('c', '<C-Left>',  '<S-Left>', { noremap = true })
vim.keymap.set('c', '<C-Right>', '<S-Right>', { noremap = true })

-- smart Ctrl+j
vim.keymap.set('n', '<C-j>', function()
  local current_win = vim.api.nvim_get_current_win()
  local target_win  = vim.fn.winnr('j')

  if target_win == vim.fn.winnr() then
    return vim.cmd('silent! TmuxNavigateDown')
  end

  local target_id = vim.fn.win_getid(target_win)
  local buf = vim.api.nvim_win_get_buf(target_id)

  if vim.bo[buf].buftype == 'terminal' then
    vim.api.nvim_set_current_win(target_id)
    vim.cmd('startinsert')
  else
    vim.cmd('silent! TmuxNavigateDown')
  end
end, { desc = 'Smart down: into terminal if below', silent = true })

vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]],
  { desc = 'Leave terminal upward', silent = true })

vim.o.showcmd = false
vim.o.showcmdloc = "last"

vim.cmd([[
  augroup CursorLineOnlyInActiveWindow
    autocmd!
    autocmd WinEnter,BufEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
  augroup END
]])

vim.opt.number = true         -- absolute line numbers
vim.opt.relativenumber = true -- relative line numbers

-- OSC52 Clipboard (ony with SSH)
if vim.env.SSH_CONNECTION then
  require("osc52").setup({
    max_length = 0,
    silent = true,
  })

  vim.keymap.set("v", "<leader>y", function()
    require("osc52").copy_visual()
  end, { desc = "Copy via OSC52" })

  vim.keymap.set("n", "<leader>yy", function()
    require("osc52").copy_operator()
  end, { desc = "Copy line via OSC52" })
end
