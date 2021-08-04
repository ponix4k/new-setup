"Basic Settings
set encoding=UTF-8
syntax on 
set tabstop=4 softtabstop=4 shiftwidth=4 
set nu expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set incsearch
set undodir=~/.vim/undodir undofile 
highlight ColorColumn ctermbg=0 guibg=lightgrey 

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'scrooloose/nerdtree'
Plugin 'vim-utils/vim-man'
Plugin 'git@github.com:ctrlpvim/ctrlp.vim'
Plugin 'git@github.com:Valloric/YouCompleteMe.git'
Plugin 'VundleVim/Vundle.vim'
Plugin 'ryanoasis/vim-devicons'
call vundle#end()

colorscheme slate

let mapleader = " "
let g:netrw_browse_split=2
let g:netrw_banner = 0
let g:netrw_winsize = 25

let g:ctrlp_use_cacheing = 0

nnoremap <leader>h :wincmd h <CR>
nnoremap <leader>j :wincmd j<CR> 
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

"NerdTree options
autocmd VimEnter * NERDTree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeShowHidden=1

" YCM   
nnoremap <silent> <leader>gd :YcmCompleter GoTo <CR> 
nnoremap <silent> <leader>gf :YcmCompleter FixIt <CR>
