#!/bin/bash -eu

# Description:
#   Activate dot files from here by symlinking them.
#   Existing real files will be backuped with .saved
#   extension, existing symlinks will be overwritten.


mk_rel_symlink() {
    local dest="$1"
    local rel_link="${2#$HOME/}"

    (
        cd $HOME
        /bin/ln -sf "$rel_link" "$dest"
    )
}

for dot_file in dot.*
do
    [[ $dot_file == ./* ]] || dot_file="$PWD/${dot_file##*/}"
    dot_file_home="${HOME}/.${dot_file##*dot.}"

    if [ -f $dot_file_home -a ! -L $dot_file_home ]
    then
        /bin/mv -v $dot_file_home ${dot_file_home}.saved
    fi

    if [ ! -L $dot_file_home ]
    then
        mk_rel_symlink $dot_file_home $dot_file
    fi
done
