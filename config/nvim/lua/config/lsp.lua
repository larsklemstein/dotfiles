vim.lsp.enable("lua_ls")
vim.lsp.enable("yaml_ls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client:supports_method("textDocument/completion") then
      vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      vim.keymap.set("i", "<C-Space>", function()
          vim.lsp.completion.get()
        end)
    end
  end,
})

vim.diagnostic.config({
    virtual_lines = true,
    update_in_insert = false,
})
