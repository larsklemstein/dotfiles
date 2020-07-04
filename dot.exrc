" only meant for "traditional vi" like nvi
" Not usefull for vim ro neovim

set nu
set ai
set ru
set tabstop=4
set shiftwidth=4

" <CTRL-Shift-T> to convert tabs to blanks
map  :%!expand -t4
