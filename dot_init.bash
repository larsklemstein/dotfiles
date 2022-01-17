#!/bin/bash

# Will initially create all required symlinks
# Existing files will be saved.


dir_basename=${PWD##*/}

for file in dot.*
do
    file_link=$HOME/.${file#dot.}
    file_dest="./$dir_basename/${file##*/}"

    echo "check $file_link"

    if [ -L "$file_link" ]
    then
       /bin/rm $file_link || exit 1
       echo "-> removed existing link $file_link" >&2
    elif [ -f "$file_link" ]
    then
       file_saved=$file_link.before_dot_init
       /bin/mv $file_link $file_saved || exit 1
       echo "-> saved existing $file_dest as $file_saved"
    fi

    ln -s $file_dest $file_link || exit 1
    echo "set $file_link" >&2
done

common_interactive_local=$HOME/.common_interactive_local_sh

if [ ! -f "$common_interactive_local" ]
then
    echo -e "# add local settings here!\n\n" > $common_interactive_local
fi
