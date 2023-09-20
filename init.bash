#!/bin/bash -ue

# Will initially create all required symlinks
# Existing files will be saved.


typeset DIR_BASENAME=${PWD##*/}

typeset GRUVBOX_GIT=https://github.com/morhetz/gruvbox

typeset PROGNAME=${0##*/}

msg() {
    echo "[$PROGNAME] $*" >&2
}

skip_profile=n

if grep -i opensuse /proc/version
then
    skip_profile=y
fi

for file in dot.*
do
    if [ $file = dot.Xresources ]
    then
        echo "Skipping $file..."
        continue
    fi

    if [ $file = dot.profile -a $skip_profile = y ]
    then
        echo "Skipping $file..."
        continue
    fi

    echo "File: $file"

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


# late tmp dir creation because for the beginning actions we need to
# be inside the .dotfiles directory

cd /tmp
tmpdir=$(mktemp -d XXXXXXXXXX)
trap "/bin/rm -rf $PWD/$tmpdir" 0 1 2

vimdir=$HOME/.vim

if [ ! -d "$vimdir" ]
then
    msg "Installing Gruvbox vim colorscheme...."
    mkdir -p $vimdir

    cd $tmpdir

    git clone --depth 1 $GRUVBOX_GIT

    mv gruvbox/colors $vimdir
    mv gruvbox/autoload $vimdir
fi

msg "Install GoMono font..."
os_info=$(uname -v)

case $os_info in
    Darwin*)
        font_dir=$HOME/Library/Fonts
        ;;
    *)
        font_dir=$HOME/.local/share/fonts
        ;;
esac

font_file=Go-Mono.zip

font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/"
font_url+="v2.1.0/$font_file"

wget $font_url

test -d $font_dir || mkdir -p $_

yes | unzip -d $font_dir $font_file

msg "...Done! Copied font files to $font_dir"

if which git 2>/dev/null
then
     git config --global init.defaultBranch main
     msg "Set git default branch to main"

     msg "!!! please set git user and email!"
fi
