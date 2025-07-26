-- Get the SSH_CLIENT environment variable
local ssh_client = os.getenv("SSH_CLIENT")

-- Check if it starts with "10.0.112.71"
if ssh_client and ssh_client:match("^10%.0%.112%.71 ") then
  vim.cmd("colorscheme retrobox")
else
  vim.cmd("colorscheme nord")
end
