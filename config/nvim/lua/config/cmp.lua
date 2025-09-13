-- Make sure builtin completion UI stays off when using nvim-cmp
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")
vim.cmd([[
  set completeopt-=preview
  set completeopt-=popup
  set completeopt-=fuzzy
]])

-- Neovim 0.11 native LSP completion can be enabled by configs/plugins.
-- Force it off globally and per attached buffer to avoid double menus.
pcall(function()
  if vim.lsp and vim.lsp.completion and vim.lsp.completion.enable then
    vim.lsp.completion.enable(false)  -- global
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        vim.lsp.completion.enable(false, args.buf)  -- buffer-local
        -- Keep sane completeopt even if a ftplugin tweaks it
        vim.schedule(function()
          vim.opt_local.completeopt = { "menu", "menuone", "noselect" }
        end)
      end,
    })
  end
end)


local cmp = require("cmp")

cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),

    -- make these explicitly select INSIDE cmp
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<Up>"]   = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
  }),

  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },   -- <- switch from vsnip to luasnip
  }, {
    { name = 'path' },
    { name = 'buffer' },
  }),

})

