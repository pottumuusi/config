" Vundle can be downloaded with:
" git clone https://github.com/VundleVim/Vundle.vim.git ${HOME}/.vim/bundle/Vundle.vim

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'jlanzarotta/bufexplorer'
Plugin 'tpope/vim-fugitive'
Plugin 'preservim/tagbar'

call vundle#end()		" required

" Line numbers
set number

" 80 character limit marker
set colorcolumn=80
highlight ColorColumn ctermbg=Magenta

" Highlight current line
set cursorline

syntax enable

" Autoindent can be set with:
" :set cindent
" :set smartindent
" :set autoindent

set autoindent

" The default was 5, disallowing cursor movement to top and bottom of window.
set scrolloff=0

" Do not add newline at the end of file
" :set nofixeol

let mapleader = ","

" Use flattened_dark colorscheme when running vimdiff from commandline
" https://stackoverflow.com/questions/2019281/load-different-colorscheme-when-using-vimdiff
if &diff
	colorscheme flattened_dark
endif

nmap <F7> :tabp<CR>
nmap <F8> :tabn<CR>

nmap <leader>it :set noexpandtab softtabstop=0 tabstop=8 shiftwidth=8 autoindent<CR>
nmap <leader>is :set tabstop=8 softtabstop=0 expandtab
	\ shiftwidth=4 smarttab autoindent<CR>

nmap <Tab> :BufExplorer<CR>
