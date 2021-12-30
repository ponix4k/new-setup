syntax on
set term=xterm-256color
set termguicolors
set encoding=utf8
set guifont=DroidSansMono\ Nerd\ Font\ 11

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
filetype on

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

"Plugins
Plugin 'plasticboy/vim-markdown'
Plugin 'airblade/vim-rooter'
Plugin 'vim-utils/vim-man'
# Plugin 'git@github.com:Valloric/YouCompleteMe.git'
Plugin 'VundleVim/Vundle.vim'

"NerdTree
Plugin 'preservim/nerdtree'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'ryanoasis/vim-devicons'

"FuzzyFinder
Plugin 'junegunn/fzf', { 'do': {-> fzf#install() } }
Plugin 'junegunn/fzf.vim'

"Theme Related Plugins
Plugin 'kaicataldo/material.vim'
Plugin 'bluz71/vim-nightfly-guicolors'
Plugin 'ghifarit53/daycula-vim' , {'branch' : 'main'}
Plugin 'artanikin/vim-synthwave84'
Plugin 'godlygeek/tabular'

call vundle#end()

let mapleader = " "
let g:netrw_browse_split=2
let g:netrw_banner = 0
let g:netrw_winsize = 25

nnoremap <leader>h :wincmd h <CR>
nnoremap <leader>j :wincmd j<CR> 
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

"NerdTree options
"autocmd VimEnter * NERDTree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :FZF<CR>
nnoremap <C-P> :Files <CR>

let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:NERDTreeNodeDelimiter = "\u00a0"
let g:NERDTreeGitStatusShowClean = 1
"let NERDTreeShowHidden=1
let g:NERDTreeGitStatusIndicatorMapCustom = { 'Staged' :'✚',
\ 'Untracked' :'✭',
\ 'Renamed' :'➜',
\ 'Unmerged' :'═',
\ 'Deleted' :'✖',
\ 'Dirty' :'✗',
\ 'Ignored' :'☒',
\ 'Clean' :'✔︎',
\ 'Unknown' :'?' }

colorscheme desert

" YCM   
# nnoremap <silent> <leader>gd :YcmCompleter GoTo <CR> 
# nnoremap <silent> <leader>gf :YcmCompleter FixIt <CR>

" NERDTrees File highlighting only the glyph/icon
" test highlight just the glyph (icons) in nerdtree:
autocmd filetype nerdtree highlight haskell_icon ctermbg=none ctermfg=Red guifg=#ffa500
autocmd filetype nerdtree highlight html_icon ctermbg=none ctermfg=Red guifg=#ffa500
autocmd filetype nerdtree highlight go_icon ctermbg=none ctermfg=Red guifg=#ffa500
