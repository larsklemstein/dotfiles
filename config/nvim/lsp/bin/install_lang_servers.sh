#!/bin/bash -eu

servers_from_npm=(
    vscode-langservers-extracted
    bash-language-server
    dockerfile-language-server-nodejs
    @microsoft/compose-language-service
    typescript
    typescript-language-server
)

servers_from_brew=(
    pyright
    rust-analyzer
<<<<<<< HEAD
=======
    lua-language-server
>>>>>>> ff8bdf5e42ed324aae677057df386c23ab8f8b06
    yaml-language-server
)

for seryamver in "${servers_from_npm[@]}"
do
    echo "Installing $server..." >&2
    npm install -g "$server"
done

for server in "${servers_from_brew[@]}"
do
    echo "Installing $server..." >&2
    brew install "$server"
done

echo "Done." >&2
