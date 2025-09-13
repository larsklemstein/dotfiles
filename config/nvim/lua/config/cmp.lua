-- ~/.config/nvim/lua/config/cmp.lua
-- nvim-cmp with signature help via cmp source (no lsp_signature.nvim)

local ok_cmp, cmp = pcall(require, "cmp")
if not ok_cmp then
  vim.notify("cmp.lua: nvim-cmp not found", vim.log.levels.WARN)
  return
end

-- Let cmp own completion UI (disable builtin popup/fuzzy/preview)
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")
vim.cmd([[
  set completeopt-=preview
  set completeopt-=popup
  set completeopt-=fuzzy
]])

-- Snippets (optional)
local ok_luasnip, luasnip = pcall(require, "luasnip")
if ok_luasnip then
  pcall(function() require("luasnip.loaders.from_vscode").lazy_load() end)
end

----------------------------------------------------------------
-- Distraction-free master toggle:
--   ON  -> normal
--   OFF -> cmp disabled + hover/diagnostic floats suppressed
----------------------------------------------------------------
vim.g.df_enabled  = false
vim.g.cmp_enabled = true

-- Save originals once
if vim.g._orig_hov_handler_global == nil then
  vim.g._orig_hov_handler_global = vim.lsp.handlers["textDocument/hover"]
end
if vim.g._orig_open_float_prev == nil then
  vim.g._orig_open_float_prev = vim.lsp.util.open_floating_preview
end
if vim.g._orig_diag_open_float == nil then
  vim.g._orig_diag_open_float = vim.diagnostic.open_float
end

local function close_all_floats()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
    if ok and cfg and cfg.relative ~= "" then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  pcall(vim.cmd, "pclose")
end

local function apply_df_state(df_on)
  if df_on then
    vim.g.cmp_enabled = false
    pcall(cmp.close)

    -- Block hover + diagnostic floats; signature is inside cmp now
    vim.lsp.handlers["textDocument/hover"] = function() end
    vim.lsp.util.open_floating_preview = function() return nil end
    vim.diagnostic.open_float = function() return nil end

    vim.api.nvim_create_augroup("DF_SUPPRESS_FLOATS", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "TextChangedI" }, {
      group = "DF_SUPPRESS_FLOATS",
      callback = close_all_floats,
      desc = "Close floats in distraction-free mode",
    })

    close_all_floats()
  else
    vim.g.cmp_enabled = true
    vim.lsp.handlers["textDocument/hover"] = vim.g._orig_hov_handler_global
    vim.lsp.util.open_floating_preview = vim.g._orig_open_float_prev
    vim.diagnostic.open_float = vim.g._orig_diag_open_float
    pcall(vim.api.nvim_del_augroup_by_name, "DF_SUPPRESS_FLOATS")
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    if vim.g.df_enabled then
      apply_df_state(true)
    else
      vim.schedule(function()
        if not vim.g.df_enabled then
          vim.opt_local.completeopt = { "menu", "menuone", "noselect" }
        end
      end)
    end
  end,
})

vim.keymap.set("n", "<leader>uc", function()
  vim.g.df_enabled = not vim.g.df_enabled
  apply_df_state(vim.g.df_enabled)
  if vim.g.df_enabled then
    vim.notify("Distraction-free: ON  (completion OFF, popups OFF)", vim.log.levels.WARN)
  else
    vim.notify("Distraction-free: OFF (completion ON, popups restored)", vim.log.levels.INFO)
  end
end, { desc = "Toggle distraction-free (cmp + popups)" })

----------------------------------------------------------------
-- nvim-cmp setup (with signature-help source)
----------------------------------------------------------------
cmp.setup({
  enabled = function() return (not vim.g.df_enabled) and vim.g.cmp_enabled end,

  snippet = {
    expand = function(args)
      if ok_luasnip then
        luasnip.lsp_expand(args.body)
      end
    end,
  },

  window = {
    completion    = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"]     = cmp.mapping.abort(),
    ["<CR>"]      = cmp.mapping.confirm({ select = true }),

    ["<C-n>"]  = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-p>"]  = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<Up>"]   = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif ok_luasnip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif ok_luasnip and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  -- IMPORTANT: add the signature-help source
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },  -- <-- signatures inside cmp popup
    (ok_luasnip and { name = "luasnip" } or nil),
  }, {
    { name = "path" },
    { name = "buffer" },
  }),
})

-- Cmdline completion (optional)
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = "buffer" } },
})
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
  matching = { disallow_symbol_nonprefix_matching = false },
})

