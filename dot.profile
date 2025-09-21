if [[ $- == *i* ]]; then
    if [[ -n $BASH_VERSION && -f ~/.bashrc ]]; then
        . ~/.bashrc
    fi
fi
