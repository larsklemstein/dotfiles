vim.g.blamer_enabled = true

vim.g.blamer_delay = 750

vim.g.blamer_show_in_visual_modes = 1
vim.g.blamer_show_in_insert_modes = 1

vim.g.blamer_prefix = '   -- '

-- Available options: <author>, <author-mail>, <author-time>, <committer>,
-- <committer-mail>, <committer-time>, <summary>, <commit-short>, <commit-long>.
vim.g.blamer_template = '<committer> <committer-time>: <summary>'

vim.g.blamer_date_format = '%Y-%m-%d %H:%M'

vim.g.blamer_relative_time = 0
