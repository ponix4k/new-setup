set nocompatible

let g:new_setup_plugin_dir = expand('~/.vim/plugged')
let g:new_setup_config_dir = expand('~/.vim/new-setup')

execute 'source ' . fnameescape(g:new_setup_config_dir . '/plugins.vim')
execute 'source ' . fnameescape(g:new_setup_config_dir . '/settings.vim')

if filereadable(expand('~/.vim/local_init.vim'))
    source ~/.vim/local_init.vim
endif
