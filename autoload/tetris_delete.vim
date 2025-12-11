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
        execute 'sleep ' . g:tetris_delete_fall_speed . 'm'
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

" Main function (single line)
function! tetris_delete#main() abort
    call tetris_delete#delete_lines(1)
endfunction

" Delete multiple lines at once
function! tetris_delete#delete_lines(count) abort
    let lines_win_ids = []
    let start_line = line('.')

    " Create windows for all lines (keep each line's windows separate)
    for i in range(a:count)
        execute "normal! " . (start_line + i) . "G"
        let win_ids = s:create_words_window()
        call add(lines_win_ids, win_ids)
        call setline('.', '')
    endfor

    " Get max block count across all lines
    let max_blocks = 0
    for win_ids in lines_win_ids
        if len(win_ids) > max_blocks
            let max_blocks = len(win_ids)
        endif
    endfor

    let move_y = line('w$') - start_line

    " Fall blocks one by one (but all lines together)
    for block_idx in range(max_blocks)
        " Collect the block at this index from each line
        let current_blocks = []
        for win_ids in lines_win_ids
            if block_idx < len(win_ids)
                call add(current_blocks, win_ids[block_idx])
            endif
        endfor

        " Fall these blocks together
        for y in range(0, move_y)
            for win_id in current_blocks
                if nvim_win_is_valid(win_id)
                    let config = nvim_win_get_config(win_id)
                    call s:move_floating_window(win_id, config.relative, config.row + 1, config.col)
                endif
            endfor
            execute 'sleep ' . g:tetris_delete_fall_speed . 'm'
        endfor
    endfor

    " Delete lines
    execute "normal! " . start_line . "G"
    execute "normal! " . a:count . "dd"

    " Close all windows
    for win_ids in lines_win_ids
        for win_id in win_ids
            if nvim_win_is_valid(win_id)
                call nvim_win_close(win_id, v:true)
            endif
        endfor
    endfor
endfunction

" Operator function for dot-repeat
function! tetris_delete#operator(...) abort
    call tetris_delete#main()
endfunction

" Visual mode function
function! tetris_delete#visual() abort
    let count = line("'>") - line("'<") + 1
    execute "normal! '<"
    call tetris_delete#delete_lines(count)
endfunction

" Command wrapper (single line uses operatorfunc for dot-repeat)
function! tetris_delete#cmd(line1, line2) abort
    if a:line1 == a:line2
        let &operatorfunc = 'tetris_delete#operator'
        call feedkeys("g@l", 'n')
    else
        execute "normal! " . a:line1 . "G"
        call tetris_delete#delete_lines(a:line2 - a:line1 + 1)
    endif
endfunction
