------------------------------------------------------------
-- Minimal, safe Neovim setup (v0.1.15)
-- LSP-free, deterministic, ergonomic
------------------------------------------------------------

------------------------------------------------------------
-- 0. Leader key
------------------------------------------------------------
vim.g.mapleader = " "

------------------------------------------------------------
-- 1. Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- 2. Plugins
------------------------------------------------------------
require("lazy").setup {
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "vague2k/vague.nvim", lazy = false, priority = 1000 },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" } },
  { "williamboman/mason.nvim", config = true },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },
  { "christoomey/vim-tmux-navigator" },

  ------------------------------------------------------------
-- Modern Git integration: gitsigns + git-blame
------------------------------------------------------------
{
  -- Git diff signs in sign column
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = { add = { text = "│" }, change = { text = "│" }, delete = { text = "_" } },
    on_attach = function(buf)
      local gs = package.loaded.gitsigns
      local map = function(l, r, d) vim.keymap.set("n", l, r, { buffer = buf, desc = d }) end
      map("]h", gs.next_hunk, "Next hunk")
      map("[h", gs.prev_hunk, "Prev hunk")
      map("<leader>hp", gs.preview_hunk, "Preview hunk")
      map("<leader>hb", function() gs.blame_line { full = true } end, "Blame line")
    end,
  },
},

{
  -- Inline git blame text
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
}

}

------------------------------------------------------------
-- 3. UI options
------------------------------------------------------------
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.autoindent = true
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

vim.cmd.colorscheme "vague"

------------------------------------------------------------
-- 4. NvimTree setup with preview & smart splits
------------------------------------------------------------
require("nvim-tree").setup {
  view = { width = 30, side = "left", preserve_window_proportions = true },
  renderer = { indent_markers = { enable = true } },
  actions = { open_file = { quit_on_open = false } },
  filters = {
    dotfiles = true,  -- <== Blendet .hidden Dateien aus
  },
  on_attach = function(bufnr)
    local api = require "nvim-tree.api"
    local view = require "nvim-tree.view"
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    api.config.mappings.default_on_attach(bufnr)

    -- Floating preview
    vim.keymap.set("n", "P", function()
      local node = api.tree.get_node_under_cursor()
      if not node or node.type ~= "file" then
        return
      end
      if vim.g._nvimtree_preview_win and vim.api.nvim_win_is_valid(vim.g._nvimtree_preview_win) then
        vim.api.nvim_win_close(vim.g._nvimtree_preview_win, true)
        vim.g._nvimtree_preview_win = nil
      end
      local width, height = math.floor(vim.o.columns * 0.7), math.floor(vim.o.lines * 0.8)
      local row, col = math.floor((vim.o.lines - height) / 2), math.floor((vim.o.columns - width) / 2)
      local lines = {}
      local fd = io.open(node.absolute_path, "r")
      if fd then
        for i = 1, 1000 do
          local l = fd:read "*line"
          if not l then
            break
          end
          table.insert(lines, l)
        end
        fd:close()
      end
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
      local ft = vim.filetype.match { filename = node.absolute_path } or "text"
      vim.api.nvim_buf_set_option(buf, "filetype", ft)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      pcall(vim.treesitter.start, buf, ft)
      vim.g._nvimtree_preview_win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
      })
      vim.api.nvim_win_set_option(vim.g._nvimtree_preview_win, "number", true)
      local close_preview = function()
        if vim.g._nvimtree_preview_win and vim.api.nvim_win_is_valid(vim.g._nvimtree_preview_win) then
          vim.api.nvim_win_close(vim.g._nvimtree_preview_win, true)
        end
        vim.g._nvimtree_preview_win = nil
        vim.api.nvim_set_current_win(vim.fn.bufwinid(bufnr))
      end
      vim.keymap.set("n", "q", close_preview, { buffer = buf, nowait = true })
      vim.keymap.set("n", "<Esc>", close_preview, { buffer = buf, nowait = true })
    end, opts "Floating preview")

    -- Smart splits beside tree
    local function get_tree_win()
      return (view.get_winnr and view.get_winnr()) or vim.fn.winnr()
    end
    vim.keymap.set("n", "s", function()
      local tree_win = get_tree_win()
      vim.cmd(tree_win .. "wincmd l")
      vim.cmd "vsplit"
      api.node.open.edit()
    end, opts "Vertical split beside tree")
    vim.keymap.set("n", "i", function()
      local tree_win = get_tree_win()
      vim.cmd(tree_win .. "wincmd l")
      vim.cmd "split"
      api.node.open.edit()
    end, opts "Horizontal split beside tree")
  end,
}

------------------------------------------------------------
-- 5. NvimTree flash + toggle mapping (restored)
------------------------------------------------------------
vim.api.nvim_set_hl(0, "NvimTreeFindCursorLine", { bg = "#fabd2f", fg = "#1d2021", bold = true })

local function _nvimtree_flash_mark()
  local view = require "nvim-tree.view"
  local win = (view.get_winnr and view.get_winnr()) or 0
  if not win or win == 0 then
    return
  end
  pcall(vim.api.nvim_set_option_value, "cursorline", true, { win = win })
  local ok, old_winhl = pcall(vim.api.nvim_get_option_value, "winhighlight", { win = win })
  if not ok then
    old_winhl = ""
  end
  local new_winhl = (old_winhl ~= "" and (old_winhl .. ",") or "") .. "CursorLine:NvimTreeFindCursorLine"
  pcall(vim.api.nvim_set_option_value, "winhighlight", new_winhl, { win = win })
  local tree_buf = vim.api.nvim_win_get_buf(win)
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = tree_buf,
    once = true,
    callback = function()
      pcall(vim.api.nvim_set_option_value, "winhighlight", old_winhl, { win = win })
    end,
  })
end

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>e", function()
  local api = require "nvim-tree.api"
  local was_open = api.tree.is_visible()
  vim.cmd "NvimTreeFindFileToggle"
  vim.schedule(function()
    if not was_open then
      _nvimtree_flash_mark()
    end
  end)
end, opts)

------------------------------------------------------------
-- 6. Telescope mappings
------------------------------------------------------------
local tb = require "telescope.builtin"
map("n", "<leader>ff", tb.find_files, opts)
map("n", "<leader>fg", tb.live_grep, opts)
map("n", "<leader>fb", tb.buffers, opts)
map("n", "<leader>fr", tb.oldfiles, opts)
map("n", "<leader>fs", tb.current_buffer_fuzzy_find, opts)

------------------------------------------------------------
-- 7. Bottom terminal toggle (final, working)
------------------------------------------------------------
local term_buf, term_win = nil, nil
local TERMINAL_HEIGHT_RATIO = 0.35

local function toggle_bottom_terminal()
  -- Close if open
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    return
  end

  -- Ensure buffer exists
  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
    term_buf = vim.api.nvim_create_buf(false, true)
  end

  -- Open split first
  local height = math.floor(vim.o.lines * TERMINAL_HEIGHT_RATIO)
  vim.cmd("botright " .. height .. "split")
  term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(term_win, term_buf)

  -- Start shell now that window exists
  if vim.bo[term_buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell, { cwd = vim.fn.getcwd() })
  end

  vim.bo[term_buf].buflisted = false
  vim.bo[term_buf].filetype = "terminal"
  vim.cmd "startinsert"
end

map("n", "<leader>tb", toggle_bottom_terminal, opts)
map("t", "<leader>tb", toggle_bottom_terminal, opts)

------------------------------------------------------------
-- 8. Yank helpers for terminal
------------------------------------------------------------
map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
map("n", "<leader>ty", function()
  vim.cmd 'normal! ggVG"+y'
  print "Terminal output yanked to system clipboard (+)"
end, opts)




------------------------------------------------------------
-- 9. Async, UV-safe format-on-save (ruff for Python, fixed)
------------------------------------------------------------

local formatters = {
  lua = { cmd = { "stylua", "--respect-ignores" }, config_files = { ".stylua.toml", "stylua.toml" } },
  python = { cmd = { "ruff", "format" }, config_files = { "pyproject.toml", "ruff.toml" } },
  javascript = { cmd = { "prettier", "--write" }, config_files = { ".prettierrc", "prettier.config.js" } },
  typescript = { cmd = { "prettier", "--write" }, config_files = { ".prettierrc", "prettier.config.js" } },
  go = { cmd = { "gofmt", "-w" }, config_files = { "go.mod" } },
  rust = { cmd = { "rustfmt" }, config_files = { "rustfmt.toml", ".rustfmt.toml" } },
}

local function get_project_root()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  return (root and root ~= "") and root or vim.fn.getcwd()
end

local function project_has_config(files)
  local root = get_project_root()
  for _, f in ipairs(files) do
    if vim.loop.fs_stat(root .. "/" .. f) then
      return true
    end
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
        vim.notify(
          "[format] " .. args[1] .. " exited with code " .. code,
          vim.log.levels.WARN
        )
        return
      end

      -- Safely reload buffer if still loaded
      local bufnr = vim.fn.bufnr(filepath)
      if bufnr >= 0 and vim.api.nvim_buf_is_loaded(bufnr) then
        local win = vim.fn.bufwinid(bufnr)
        if win ~= -1 and vim.api.nvim_win_is_valid(win) then
          local ok, curpos = pcall(vim.api.nvim_win_get_cursor, win)
          vim.cmd("checktime " .. bufnr)
          if ok then
            pcall(vim.api.nvim_win_set_cursor, win, curpos)
          end
        else
          -- No window open for that buffer; just checktime silently
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
-- 10. Filetype & syntax detection
------------------------------------------------------------
vim.cmd [[
  filetype on
  filetype plugin indent on
  syntax on
]]
vim.api.nvim_create_autocmd({ "BufNewFile", "TextChanged", "TextChangedI", "BufWritePost" }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "" or vim.bo.filetype == "text" then
      vim.cmd "filetype detect"
    end
  end,
})


------------------------------------------------------------
-- 11. More or less sophisticated keympaps
------------------------------------------------------------
vim.keymap.set("n", "<leader>rf", function()
  -- Insert file under cursor below the current line
  vim.cmd("read " .. vim.fn.expand "<cfile>")
end, { desc = "Insert contents of file under cursor" })

vim.keymap.set('n', '<leader>hh', function()
  require('nvim-tree.api').tree.toggle_hidden_filter()
end, { desc = 'nvim-tree: Toggle dotfiles' })

vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', {
  noremap = true,
  silent = true,
  desc = 'Quit all'
})

-- Remove non-breaking spaces before write
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[silent! %s/\%xa0/ /ge]],
})

vim.opt.backup = false
vim.opt.swapfile = false

vim.opt.backupcopy = "yes"

vim.opt.autoread = true
