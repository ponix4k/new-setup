syntax enable
set encoding=utf-8
set fileencoding=utf-8
set backspace=indent,eol,start
set hidden
set number
set ruler
set mouse=a
set wildmenu
set wildmode=list:longest,list:full
set autoread
set modeline
set modelines=10
set title
set laststatus=2
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
set ignorecase
set smartcase
set hlsearch
set incsearch
set nowrap
set noswapfile
set undofile
set updatetime=300
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite,*/node_modules/*

if has('termguicolors')
    set termguicolors
endif

if has('nvim')
    set undodir=~/.local/state/nvim/undo
else
    set undodir=~/.vim/undo
    set guifont=DroidSansMono\ Nerd\ Font\ 11
endif

silent! colorscheme molokai
let mapleader = ' '

" Window, tab, buffer, and search navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
nnoremap <silent> <leader><space> :nohlsearch<CR>
nnoremap n nzzzv
nnoremap N Nzzzv
vnoremap < <gv
vnoremap > >gv

" NERDTree
let g:NERDTreeChDirMode = 2
let g:NERDTreeIgnore = ['node_modules', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeWinSize = 40
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
nnoremap <silent> <leader>n :NERDTreeFocus<CR>
nnoremap <silent> <C-n> :NERDTreeFind<CR>
nnoremap <silent> <C-t> :NERDTreeToggle<CR>
nnoremap <silent> <F2> :NERDTreeFind<CR>
nnoremap <silent> <F3> :NERDTreeToggle<CR>

" FZF and ripgrep
let g:fzf_layout = { 'down': '~40%' }
let g:fzf_preview_window = ['right:60%', 'ctrl-/']
let g:fzf_action = { 'ctrl-t': 'tab split', 'ctrl-x': 'split', 'ctrl-v': 'vsplit' }
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>y :History:<CR>
if executable('rg')
    let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
    set grepprg=rg\ --vimgrep
endif

" Git and sessions
nnoremap <leader>ga :Gwrite<CR>
nnoremap <leader>gc :Git commit --verbose<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git pull<CR>
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Gvdiffsplit<CR>
nnoremap <leader>so :OpenSession<Space>
nnoremap <leader>ss :SaveSession<Space>
nnoremap <leader>sd :DeleteSession<CR>

" EasyMotion, Tagbar, terminal, and utilities
let g:EasyMotion_smartcase = 1
nmap <leader><leader>j <Plug>(easymotion-j)
nmap <leader><leader>k <Plug>(easymotion-k)
nnoremap <silent> <F4> :TagbarToggle<CR>
nnoremap <silent> <leader>sh :terminal<CR>
command! FixWhitespace %s/\s\+$//e

" Airline and Nerd Font symbols
let g:airline_theme = 'powerlineish'
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1

" Snippets and diagnostics
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<c-b>'
let g:ale_linters = {}
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 0

" Common command-line corrections
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q

augroup new_setup
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') | execute "normal! g`\"" | endif
    autocmd FileType make setlocal noexpandtab
    autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
    autocmd FileType c,cpp setlocal tabstop=4 shiftwidth=4 expandtab
    autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
    autocmd FileType javascript setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
    autocmd FileType python setlocal tabstop=8 shiftwidth=4 softtabstop=4 expandtab colorcolumn=79
    autocmd FileType ruby setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
augroup END

let g:go_fmt_command = 'goimports'
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:javascript_enable_domhtmlcss = 1
let python_highlight_all = 1
let g:vim_svelte_plugin_load_full_syntax = 1
let g:vue_disable_pre_processors = 1
let g:vim_vue_plugin_load_full_syntax = 1
