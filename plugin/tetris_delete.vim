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

" Plug mapping with dot-repeat support (no plugin required)
nnoremap <silent> <Plug>(TetrisDelete) :set operatorfunc=tetris_delete#operator<CR>g@l

" Command (uses Plug mapping for dot-repeat support)
command! TetrisDelete execute "normal \<Plug>(TetrisDelete)"

let &cpo = s:save_cpo
unlet s:save_cpo
