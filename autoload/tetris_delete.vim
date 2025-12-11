" vim-tetris-delete - Autoload functions
" Maintainer: Rasukarusan
" License: MIT

" Check if clipboard window exists
function! s:is_exist_clipboard_window() abort
    return get(g:, 'tetris_delete_clipboard_wid', 0) != 0
        \ && nvim_win_is_valid(g:tetris_delete_clipboard_wid) == v:true
endfunction

" Create clipboard window
function! s:create_clipboard_window() abort
    if s:is_exist_clipboard_window()
        return g:tetris_delete_clipboard_wid
    endif

    let window_width = nvim_win_get_width(0)
    let window_height = nvim_win_get_height(0)
    let width = float2nr(window_width * g:tetris_delete_clipboard_width)
    let config = {
        \ 'relative': 'editor',
        \ 'row': 1,
        \ 'col': window_width - width,
        \ 'width': width,
        \ 'height': float2nr(window_height * g:tetris_delete_clipboard_height),
        \ 'anchor': 'NW',
        \ 'style': 'minimal',
        \ }

    let win_id = s:create_window(config)
    hi TetrisDeleteClipboard guifg=#ffffff guibg=#aff577
    call nvim_win_set_option(win_id, 'winhighlight', 'Normal:TetrisDeleteClipboard')
    call nvim_win_set_option(win_id, 'winblend', g:tetris_delete_clipboard_blend)
    call nvim_win_set_config(win_id, config)
    set nowrap

    return win_id
endfunction

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
    " when `set nonumber` not need adjustment
    if &number == 0
        return 0
    endif
    " not support over 1000 line file
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

" Move window to clipboard window with animation
function! s:move_split_window_to_clip_window(win_id) abort
    let clipboard_config = nvim_win_get_config(g:tetris_delete_clipboard_wid)
    let clipboard = s:winid2tabnr(g:tetris_delete_clipboard_wid)
    execute clipboard . 'windo :'
    let clipboard_last_line = line('w$')

    let y = 0
    let is_max = v:false
    let config = nvim_win_get_config(a:win_id)
    let max_y = float2nr(config.row - clipboard_config.row - clipboard_last_line + 1)

    for _ in range(0, float2nr(clipboard_config.col))
        let config = nvim_win_get_config(a:win_id)
        let y += 1
        if is_max
            call s:move_floating_window(a:win_id, config.relative, config.row, config.col + 1)
        else
            call s:move_floating_window(a:win_id, config.relative, config.row - 1, config.col + 1)
        endif
        if y == max_y
            let is_max = v:true
        endif
        sleep 1ms
    endfor
endfunction

" Get text from window
function! s:get_text(win_id) abort
    let win = s:winid2tabnr(a:win_id)
    execute win . 'windo :'
    return getline('.')
endfunction

" Convert window ID to tab number
function! s:winid2tabnr(win_id) abort
    return win_id2tabwin(a:win_id)[1]
endfunction

" Generate random number
function! s:random(max) abort
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:]) % a:max
endfunction

" Main function - public interface
function! tetris_delete#main() abort
    " Ensure clipboard window exists
    if g:tetris_delete_auto_clipboard && !s:is_exist_clipboard_window()
        let g:tetris_delete_clipboard_wid = s:create_clipboard_window()
        call s:focus_to_main_window()
    endif

    if !s:is_exist_clipboard_window()
        echohl WarningMsg
        echo "Clipboard window not open. Run :TetrisDeleteOpen first."
        echohl None
        return
    endif

    " Create word windows
    let win_ids = s:create_words_window()

    " Fall current line
    call setline('.', '')
    for win_id in win_ids
        call s:fall_window(win_id)
    endfor
    execute 'normal dd'

    " Move windows to clipboard window
    let text = ''
    for win_id in win_ids
        call s:move_split_window_to_clip_window(win_id)
        let text .= s:get_text(win_id)
    endfor

    " Set current line string to clipboard window
    let clipboard = s:winid2tabnr(g:tetris_delete_clipboard_wid)
    execute clipboard . 'windo :'
    call setline('.', text)
    redraw
    execute 'normal o'
    call s:focus_to_main_window()

    " Close each floating window
    for win_id in win_ids
        call nvim_win_close(win_id, v:true)
    endfor
endfunction

" Open clipboard window
function! tetris_delete#open_clipboard() abort
    if s:is_exist_clipboard_window()
        echo "Clipboard window already open."
        return
    endif
    let g:tetris_delete_clipboard_wid = s:create_clipboard_window()
    call s:focus_to_main_window()
    echo "Clipboard window opened."
endfunction

" Close clipboard window
function! tetris_delete#close_clipboard() abort
    if !s:is_exist_clipboard_window()
        echo "Clipboard window not open."
        return
    endif
    call nvim_win_close(g:tetris_delete_clipboard_wid, v:true)
    let g:tetris_delete_clipboard_wid = 0
    echo "Clipboard window closed."
endfunction

" Toggle clipboard window
function! tetris_delete#toggle_clipboard() abort
    if s:is_exist_clipboard_window()
        call tetris_delete#close_clipboard()
    else
        call tetris_delete#open_clipboard()
    endif
endfunction
