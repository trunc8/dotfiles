set nocompatible
syntax on
set shortmess+=I

" Line numbers (relative + absolute on current line)
set number
set relativenumber

set laststatus=2
set backspace=indent,eol,start
set hidden

" Case-insensitive search unless uppercase is used
set ignorecase
set smartcase
set incsearch

nmap Q <Nop>
set noerrorbells visualbell t_vb=
set mouse+=a

" Indentation
set smartindent
set shiftwidth=2
set expandtab
set tabstop=2
set smarttab

" Show whitespace
set listchars=tab:>-,trail:-,nbsp:_
set list

" Clipboard
set clipboard=unnamedplus

" Colorscheme
colorscheme monokai
