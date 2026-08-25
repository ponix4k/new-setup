let g:new_setup_plugin_dir = stdpath('data') . '/plugged'
let g:new_setup_config_dir = stdpath('config') . '/new-setup'

execute 'source ' . fnameescape(g:new_setup_config_dir . '/plugins.vim')
execute 'source ' . fnameescape(g:new_setup_config_dir . '/settings.vim')

if filereadable(stdpath('config') . '/local_init.vim')
    execute 'source ' . fnameescape(stdpath('config') . '/local_init.vim')
endif
