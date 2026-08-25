call plug#begin(g:new_setup_plugin_dir)

" Core editing and navigation
Plug 'tpope/vim-sensible'
Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-rooter'
Plug 'vim-utils/vim-man'
Plug 'christoomey/vim-tmux-navigator'
Plug 'preservim/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'
Plug 'Raimondi/delimitMate'
Plug 'Yggdroot/indentLine'
Plug 'godlygeek/tabular'
Plug 'preservim/tagbar'

" Git, diagnostics, status, and sessions
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'airblade/vim-gitgutter'
Plug 'dense-analysis/ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

" Formatting and validation
Plug 'ntpeters/vim-better-whitespace'
Plug 'mattn/emmet-vim'
Plug 'skanehira/docker-compose.vim'
Plug 'twbs/bootlint'
Plug 'adrienverge/yamllint'
Plug 'codenothing/jsonlint'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Language support from the Vim Bootstrap profile
Plug 'vim-scripts/c.vim', { 'for': ['c', 'cpp'] }
Plug 'ludwig/split-manpage.vim'
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'phpactor/phpactor', { 'for': 'php' }
Plug 'stephpy/vim-php-cs-fixer', { 'for': 'php' }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'raimon49/requirements.txt.vim', { 'for': 'requirements' }
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'tpope/vim-rake', { 'for': 'ruby' }
Plug 'tpope/vim-projectionist', { 'for': 'ruby' }
Plug 'thoughtbot/vim-rspec', { 'for': 'ruby' }
Plug 'ecomba/vim-ruby-refactoring', { 'for': 'ruby' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'leafOfTree/vim-svelte-plugin', { 'for': 'svelte' }
Plug 'posva/vim-vue', { 'for': 'vue' }
Plug 'leafOfTree/vim-vue-plugin', { 'for': 'vue' }
Plug 'lifepillar/pgsql.vim', { 'for': 'sql' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" Themes
Plug 'kaicataldo/material.vim'
Plug 'bluz71/vim-nightfly-guicolors'
Plug 'ghifarit53/daycula-vim', { 'branch': 'main' }
Plug 'artanikin/vim-synthwave84'
Plug 'tomasr/molokai'

if filereadable(g:new_setup_config_dir . '/local_bundles.vim')
    execute 'source ' . fnameescape(g:new_setup_config_dir . '/local_bundles.vim')
endif

call plug#end()
filetype plugin indent on
