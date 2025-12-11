# vim-tetris-delete

Tetris-style line deletion with colorful floating Windows for NeoVim.

## Description

Delete a line with Tetris-style falling animation. The line splits into colorful blocks and falls down!

![Demo](https://user-images.githubusercontent.com/17779386/69768177-e7e39200-11c2-11ea-8c96-14b6a431dfc8.gif)

## Requirements

- NeoVim 0.4.0+ (floating window support required)

## Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Rasukarusan/vim-tetris-delete'
```

### Using [dein.vim](https://github.com/Shougo/dein.vim)

```vim
call dein#add('Rasukarusan/vim-tetris-delete')
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'Rasukarusan/vim-tetris-delete'
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ 'Rasukarusan/vim-tetris-delete' }
```

## Usage

1. Move cursor to a line you want to delete
2. Run `:TetrisDelete`
3. Watch the line split into colorful blocks and fall!

## Configuration

```vim
" Key mapping (use <Plug> for dot-repeat support)
nmap <silent> T <Plug>(TetrisDelete)

" Number of blocks to split line into (default: 7)
let g:tetris_delete_split_num = 5

" Fall speed in milliseconds (default: 4, lower = faster)
let g:tetris_delete_fall_speed = 4
```

Using `<Plug>(TetrisDelete)` enables `.` to repeat the action.

## License

MIT
