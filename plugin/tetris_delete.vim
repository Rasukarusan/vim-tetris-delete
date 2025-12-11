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

if !exists('g:tetris_delete_fall_speed')
    let g:tetris_delete_fall_speed = 4
endif

" Plug mapping with dot-repeat support
nnoremap <silent> <Plug>(TetrisDelete) :<C-u>set operatorfunc=tetris_delete#operator<CR>g@l
xnoremap <silent> <Plug>(TetrisDelete) :<C-u>call tetris_delete#visual()<CR>

" Command
command! -range TetrisDelete call tetris_delete#cmd(<line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
