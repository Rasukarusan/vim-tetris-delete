" vim-tetris-delete - Autoload functions
" Maintainer: Rasukarusan
" License: MIT

" Create a floating window
function! s:create_window(config) abort
    let buf = nvim_create_buf(v:false, v:true)
    let win_id = nvim_open_win(buf, v:true, a:config)
    return win_id
endfunction

" Move floating window
function! s:move_floating_window(win_id, relative, row, col) abort
    let newConfig = {'relative': a:relative, 'row': a:row, 'col': a:col}
    call nvim_win_set_config(a:win_id, newConfig)
    redraw
endfunction

" Focus to main window
function! s:focus_to_main_window() abort
    execute "0windo :"
endfunction

" Get column offset
function! s:get_col() abort
    if &number == 0
        return 0
    endif
    return 4
endfunction

" Split current line into words
function! s:split_words() abort
    let words = split(getline('.'), '\zs')
    let result = []
    let index = 0
    let i = 0
    let word = ''
    let split_num = g:tetris_delete_split_num

    while i < len(words)
        let word = word . words[i]
        if i % (len(words)/split_num) == 0 && i != 0
            call insert(result, word, index)
            let word = ''
            let index += 1
        endif
        let i += 1
    endwhile
    call insert(result, word, index)

    return result
endfunction

" Fall window animation
function! s:fall_window(win_id) abort
    let move_y = line('w$') - line('.')
    let config = nvim_win_get_config(a:win_id)
    for y in range(0, move_y)
        call s:move_floating_window(a:win_id, config.relative, config.row + y + 1, config.col)
        sleep 4ms
    endfor
endfunction

" Generate random number
function! s:random(max) abort
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:]) % a:max
endfunction

" Set random color to window
function! s:set_color_random(win_id) abort
    let color = '#' . printf("%x", s:random(16)) . printf("%05x", s:random(69905))
    let hl_name = 'TetrisDeleteBG' . a:win_id
    execute 'hi' hl_name 'guifg=#ffffff' 'guibg=' . color
    call nvim_win_set_option(a:win_id, 'winhighlight', 'Normal:'.hl_name)
endfunction

" Create windows for each word
function! s:create_words_window() abort
    let row = line('.') - line('w0')
    let col = s:get_col()
    let win_ids = []
    let words = s:split_words()

    for word in words
        let width = strdisplaywidth(word)
        if width == 0
            continue
        endif
        let config = {
            \ 'relative': 'editor',
            \ 'row': row,
            \ 'col': col,
            \ 'width': width,
            \ 'height': 1,
            \ 'anchor': 'NW',
            \ 'style': 'minimal',
            \ }
        let win_id = s:create_window(config)
        call add(win_ids, win_id)

        call s:set_color_random(win_id)

        call setline('.', word)
        call s:focus_to_main_window()
        let col += width
    endfor

    return win_ids
endfunction

" Main function
function! tetris_delete#main() abort
    " Create word windows
    let win_ids = s:create_words_window()

    " Clear current line and fall
    call setline('.', '')
    for win_id in win_ids
        call s:fall_window(win_id)
    endfor

    " Delete the line
    execute 'normal dd'

    " Close floating windows
    for win_id in win_ids
        call nvim_win_close(win_id, v:true)
    endfor
endfunction
