set tabstop=4
set shiftwidth=4
set ru
set ai

" --- <STRG-t>: replace tabs through 4 spaces
map  : %!expand -it4

" --- <F10> = numbers on, <Shift-F10> = numbers off
map [21~ : set number
map [21;2~ : set nonumber
