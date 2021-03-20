set syntax=enable

set title
set ambiwidth=double
set tabstop=2
set expandtab
set shiftwidth=2
set smartindent
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set nrformats-=octal
set hidden
set history=100
set virtualedit=block
set whichwrap=b,s,[,],<,>
set backspace=indent,eol,start
set hlsearch
set ignorecase
set incsearch
set smartcase
set laststatus=2
set nocompatible
set clipboard=unnamedplus
set encoding=utf8

" commands
command! DeleteAnsi %s/\[[0-9;]*m//g
