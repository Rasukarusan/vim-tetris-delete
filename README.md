# vim-tetris-delete

Tetris-style line deletion with colorful floating windows for NeoVim.

## Description

Split current line strings and create floating windows.
Fall floating windows and move those to north west.

![Description](https://user-images.githubusercontent.com/17779386/69766815-1199ba80-11bd-11ea-9a90-da266c66e44f.gif)

- Usecase: Clipboard History

![Demo2](https://user-images.githubusercontent.com/17779386/69894978-2c119680-136b-11ea-9cc1-98cc88e64692.gif)

## Demo

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

### Manual Installation

```bash
git clone https://github.com/Rasukarusan/vim-tetris-delete \
    ~/.local/share/nvim/site/pack/plugins/start/vim-tetris-delete
```

## Usage

1. Open a file in NeoVim
2. Move cursor to a line you want to delete
3. Press `T` (default) or run `:TetrisDelete`
4. Watch the line split into colorful blocks that fall and fly to the clipboard window!

## Commands

| Command | Description |
|---------|-------------|
| `:TetrisDelete` | Delete current line with Tetris animation |
| `:TetrisDeleteOpen` | Open the clipboard window |
| `:TetrisDeleteClose` | Close the clipboard window |
| `:TetrisDeleteToggle` | Toggle the clipboard window |

## Configuration

Add these to your `init.vim` or `init.lua` to customize:

```vim
" Key mapping for Tetris delete (default: 'T')
let g:tetris_delete_key = '<Leader>d'

" Number of blocks to split line into (default: 7)
let g:tetris_delete_split_num = 5

" Clipboard window width ratio (default: 0.4)
let g:tetris_delete_clipboard_width = 0.3

" Clipboard window height ratio (default: 0.8)
let g:tetris_delete_clipboard_height = 0.6

" Clipboard window transparency 0-100 (default: 60)
let g:tetris_delete_clipboard_blend = 40

" Auto-open clipboard window (default: 1)
let g:tetris_delete_auto_clipboard = 1

" Disable default mappings (default: 0)
let g:tetris_delete_no_mappings = 1
```

## Help

After installation, run `:helptags ALL` then use `:help tetris-delete` for full documentation.

## License

MIT
