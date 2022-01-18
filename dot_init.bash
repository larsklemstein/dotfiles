#!/bin/bash -ue

# Will initially create all required symlinks
# Existing files will be saved.


typeset DIR_BASENAME=${PWD##*/}

typeset GRUVBOX_GIT=https://github.com/morhetz/gruvbox

typeset PROGNAME=${0##*/}


msg() {
    echo "[$PROGNAME] $*" >&2
}

msg Hello

for file in dot.*
do
    file_link=$HOME/.${file#dot.}
    file_dest="./$DIR_BASENAME/${file##*/}"

    if [ -L "$file_link" ]
    then
       /bin/rm $file_link
       msg "-> removed existing link $file_link" >&2
    elif [ -f "$file_link" ]
    then
       file_saved=$file_link.before_dot_init
       /bin/mv $file_link $file_saved
       msg "-> saved existing $file_dest as $file_saved"
    fi

    ln -s $file_dest $file_link
    msg "set $file_link" >&2
done

common_interactive_local=$HOME/.common_interactive_local_sh

if [ ! -f "$common_interactive_local" ]
then
    echo -e "# add local settings here!\n\n" > $common_interactive_local
    msg "Created (empty) $common_interactive_local"
fi

vimdir=$HOME/.vim

if [ ! -d "$vimdir" ]
then
    msg "Installing Gruvbox vim colorscheme...."
    mkdir -p $vimdir

    tmpdir=$(mktemp -p /tmp -d XXXXXXXXXX)
    trap '/bin/rm -rf $tmpdir' 0 1 2

    cd $tmpdir

    git clone --depth 1 $GRUVBOX_GIT

    mv gruvbox/colors $vimdir
    mv gruvbox/autoload $vimdir
fi
