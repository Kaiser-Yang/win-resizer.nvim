# win-resizer.nvim

Humane commands and APIs for resizing nvim windows.

## Installation

With `lazy.nvim`:

```lua
return {
    'Kaiser-Yang/win-resizer.nvim',
    lazy = false,
    config = function()
        require('win.resizer').setup({
            ignore_filetypes = {
                -- put the files you don't want them be influenced by win-resizer here
            }
        })
    end
```

## Quick Start

You may want to set up those key mappings:

```lua
local resize = require('win.resizer').resize
local map_set = vim.keymap.set
local delta = 3
map_set({ 'n' }, '<up>', function()
    local _ = resize(0, 'top', delta, true) or
        resize(0, 'bottom', -delta, true) or
        resize(0, 'top', delta, false) or
        resize(0, 'bottom', -delta, false)
end, { desc = 'Smart resize up' })
map_set({ 'n' }, '<down>', function()
    local _ = resize(0, 'top', -delta, true) or
        resize(0, 'bottom', delta, true) or
        resize(0, 'top', -delta, false) or
        resize(0, 'bottom', delta, false)
end, { desc = 'Smart resize down' })
map_set({ 'n' }, '<left>', function()
    local _ = resize(0, 'right', -delta, true) or
        resize(0, 'left', delta, true) or
        resize(0, 'right', -delta, false) or
        resize(0, 'left', delta, false)
end, { desc = 'Smart resize left' })
map_set({ 'n' }, '<right>', function()
    local _ = resize(0, 'right', delta, true) or
        resize(0, 'left', -delta, true) or
        resize(0, 'right', delta, false) or
        resize(0, 'left', -delta, false)
end, { desc = 'Smart resize right' })
```

Let me explain what happens for the `<right>` key. First the `<right>` try to make the right border
of the window increase by `delta`. If it fails (which means there is no window on the right or
there is a window whose file type is in `ignore_filetypes`), it tries to make the left border of the
window decrease by `delta`. If it fails again (which means there is no window on the left or there
is a window whose file type is in `ignore_filetypes`), it tries to make the right border of the
window increase by `delta` without considering `ignore_filetypes`. If it fails again (which
means there is no window on the right), it tries to make the left border of the window decrease by
`delta` without considering `ignore_filetypes`.

Or you may not like these smart resizing, you can use the simple ones:

```lua
local delta = 3
local map_set = vim.keymap.set
map_set({ 'n' }, '<up>', function()
    resize(0, 'top', delta, true)
end, { desc = 'Increase top border' })
map_set({ 'n' }, '<s-up>', function()
    resize(0, 'top', -delta, true)
end, { desc = 'Decrease top border' })
map_set({ 'n' }, '<right>', function()
    resize(0, 'right', delta, true)
end, { desc = 'Increase right border' })
map_set({ 'n' }, '<s-right>', function()
    resize(0, 'right', -delta, true)
end, { desc = 'Decrease right border' })
map_set({ 'n' }, '<down>', function()
    resize(0, 'bottom', delta, true)
end, { desc = 'Increase bottom border' })
map_set({ 'n' }, '<s-down>', function()
    resize(0, 'bottom', -delta, true)
end, { desc = 'Decrease bottom border' })
map_set({ 'n' }, '<left>', function()
    resize(0, 'left', delta, true)
end, { desc = 'Increase left border' })
map_set({ 'n' }, '<s-left>', function()
    resize(0, 'left', -delta, true)
end, { desc = 'Decrease left border' })
```

## Command

There is a command `WinResizer` for resizing current window.

Examples:

```vim
" Increase the top border of the current window by 1
:WinResizer top
" Decrease the top border of the current window by 1
:WinResizer top -1
" Increase the right border of the current window by 1 without considering ignore_filetypes
:WinResizer right 1 false
```
