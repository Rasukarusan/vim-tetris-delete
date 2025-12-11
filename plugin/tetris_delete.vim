" vim-tetris-delete - Tetris-style line deletion with floating windows
" Maintainer: Rasukarusan
" License: MIT

" Prevent loading twice
if exists('g:loaded_tetris_delete')
    finish
endif
let g:loaded_tetris_delete = 1

" Save compatibility options
let s:save_cpo = &cpo
set cpo&vim

" Configuration variables
if !exists('g:tetris_delete_key')
    let g:tetris_delete_key = 'T'
endif

if !exists('g:tetris_delete_split_num')
    let g:tetris_delete_split_num = 7
endif

if !exists('g:tetris_delete_clipboard_width')
    let g:tetris_delete_clipboard_width = 0.4
endif

if !exists('g:tetris_delete_clipboard_height')
    let g:tetris_delete_clipboard_height = 0.8
endif

if !exists('g:tetris_delete_clipboard_blend')
    let g:tetris_delete_clipboard_blend = 60
endif

if !exists('g:tetris_delete_auto_clipboard')
    let g:tetris_delete_auto_clipboard = 1
endif

" Commands
command! TetrisDelete call tetris_delete#main()
command! TetrisDeleteOpen call tetris_delete#open_clipboard()
command! TetrisDeleteClose call tetris_delete#close_clipboard()
command! TetrisDeleteToggle call tetris_delete#toggle_clipboard()

" Default key mapping
if !exists('g:tetris_delete_no_mappings') || !g:tetris_delete_no_mappings
    execute 'nnoremap <silent> ' . g:tetris_delete_key . ' :TetrisDelete<CR>'
endif

" Restore compatibility options
let &cpo = s:save_cpo
unlet s:save_cpo
