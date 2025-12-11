" vim-tetris-delete - Tetris-style line deletion with floating windows
" Maintainer: Rasukarusan
" License: MIT

if exists('g:loaded_tetris_delete')
    finish
endif
let g:loaded_tetris_delete = 1

let s:save_cpo = &cpo
set cpo&vim

" Configuration
if !exists('g:tetris_delete_split_num')
    let g:tetris_delete_split_num = 7
endif

" Command
command! TetrisDelete call tetris_delete#main()

let &cpo = s:save_cpo
unlet s:save_cpo
