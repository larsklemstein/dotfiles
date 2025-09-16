-- ~/.config/nvim/lua/config/flash.lua
local M = {}

function M.setup()
  require("flash").setup({
    labels = "asdfghjklqwertyuiopzxcvbnm",
    highlight = { backdrop = false },   -- <- no greying out
    jump = { autojump = false },        -- show labels even if 1 match
    modes = {
      char = {
        enabled = true,                 -- enhance f/t/F/T
        jump_labels = true,             -- show per-target labels
        multi_line = false,             -- set true if you want cross-line f/t
      },
      search = { enabled = false },
      treesitter = { enabled = false },
    },
  })

  vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ff0000", bold = true })   -- red + bold
  vim.api.nvim_set_hl(0, "FlashMatch", { fg = "#ff5555", underline = true }) -- optional tweak


  local flash = require("flash")

  -- Explicitly map f/F/t/T to flash's char mode
  vim.keymap.set({ "n", "x", "o" }, "f", function()
    flash.jump({ mode = "char", search = { forward = true,  wrap = false }, label = { reuse = "lowercase" } })
  end, { desc = "Flash f" })

  vim.keymap.set({ "n", "x", "o" }, "F", function()
    flash.jump({ mode = "char", search = { forward = false, wrap = false }, label = { reuse = "lowercase" } })
  end, { desc = "Flash F" })

  vim.keymap.set({ "n", "x", "o" }, "t", function()
    flash.jump({
      mode = "char",
      search = { forward = true,  wrap = false },
      jump = { pos = "start" },   -- like native 't': stop before
      label = { reuse = "lowercase" },
    })
  end, { desc = "Flash t" })

  vim.keymap.set({ "n", "x", "o" }, "T", function()
    flash.jump({
      mode = "char",
      search = { forward = false, wrap = false },
      jump = { pos = "start" },   -- like native 'T'
      label = { reuse = "lowercase" },
    })
  end, { desc = "Flash T" })

  -- Optional extra motions (keep if you like)
  vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash jump" })
  vim.keymap.set({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash Treesitter" })
  vim.keymap.set("o", "r", flash.remote, { desc = "Flash remote" })
  vim.keymap.set({ "o", "x" }, "R", flash.treesitter_search, { desc = "Flash Treesitter Search" })
end

return M

