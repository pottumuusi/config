" Vundle can be downloaded with:
" git clone https://github.com/VundleVim/Vundle.vim.git ${HOME}/.vim/bundle/Vundle.vim

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'jlanzarotta/bufexplorer'
Plugin 'tpope/vim-fugitive'

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

let mapleader = ","

nmap <F7> :tabp<CR>
nmap <F8> :tabn<CR>

nmap <leader>it :set noexpandtab softtabstop=0 tabstop=8 shiftwidth=8<CR>
nmap <leader>is :set tabstop=8 softtabstop=0 expandtab
	\ shiftwidth=4 smarttab<CR>
