#!/bin/bash -eu

servers_from_npm=(
    @microsoft/compose-language-service
    bash-language-server
    dockerfile-language-server-nodejs
    typescript
    typescript-language-server
    vscode-langservers-extracted
    @ansible/ansible-language-serve
)

servers_from_brew=(
    bash-language-server
    shfmt
    lua-language-server
    pyright
    rust-analyzer
    terraform-lsp
    yamlfmt
    yaml-language-server
    prettier
)

for server in "${servers_from_npm[@]}"; do
    echo "npm install ${server}..." >&2
    npm install -g "$server"
done

for server in "${servers_from_brew[@]}"; do
    echo "brew install ${server}..." >&2
    brew install "$server"
done

echo 'Done.' >&2
