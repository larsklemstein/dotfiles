require("lsp_signature").setup({
  bind = true,
  floating_window = true,
  hint_enable = false,
  doc_lines = 10,              -- show up to 10 lines from the docstring
  max_height = 12,
  max_width = 80,
  toggle_key = "<C-s>",        -- press in insert mode to toggle
})

