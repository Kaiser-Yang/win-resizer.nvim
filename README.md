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

-- You may want change left border first, then set this to 'left'
local first_left_or_right = 'right'
-- You may want change bottom border first, then set this to 'bottom'
local first_top_or_bottom = 'top'
-- You need not change the following code
local second_left_or_right = first_left_or_right == 'right' and 'left' or 'right'
local second_top_or_bottom = first_top_or_bottom == 'bottom' and 'top' or 'bottom'

-- How many lines or columns to resize, make sure it is a positive integer
local abs_delta = 3

-- Choose your favorite key mappings
-- Keys in border_to_key will try first_left_or_right or first_top_or_bottom first
local border_to_key = {
    top = '<up>',
    bottom = '<down>',
    left = '<left>',
    right = '<right>',
}
-- Keys in border_to_reverse_key will try second_left_or_right or second_top_or_bottom first
local border_to_reverse_key = {
    top = '<s-up>',
    bottom = '<s-down>',
    left = '<s-left>',
    right = '<s-right>',
}

-- Smart resize, usually you don't need to change this
for _, border in pairs({ 'top', 'bottom', 'left', 'right' }) do
    local delta = (border == first_left_or_right or border == first_top_or_bottom)
        and abs_delta
        or -abs_delta
    local first = (border == first_left_or_right or border == second_left_or_right)
        and first_left_or_right
        or first_top_or_bottom
    local second = first == first_left_or_right and second_left_or_right or second_top_or_bottom
    local desc = 'Smart resize ' .. first .. ' ' .. border
    local desc_reverse = 'Smart resize ' .. second .. ' ' .. border
    map_set({ 'n' }, border_to_key[border], function()
        local _ = resize(0, first, delta, true) or
            resize(0, second, -delta, true) or
            resize(0, first, delta, false) or
            resize(0, second, -delta, false)
    end, { desc = desc })
    map_set({ 'n' }, border_to_reverse_key[border], function()
        local _ = resize(0, second, -delta, true) or
            resize(0, first, delta, true) or
            resize(0, second, -delta, false) or
            resize(0, first, delta, false)
    end, { desc = desc_reverse })
end
```

Let me explain what happens for the `<right>` key. First the `<right>` try to make the right border
of the window move to right. If it fails (which means there is no window on the right or
there is a window whose file type is in `ignore_filetypes`), it tries to make the left border of the
window move to right. If it fails again (which means there is no window on the left or there
is a window whose file type is in `ignore_filetypes`), it tries to make the right border of the
window move to right without considering `ignore_filetypes`. If it fails again (which
means there is no window on the right), it tries to make the left border of the window move to
right without considering `ignore_filetypes`. For the `<s-right>` key, it will try with reverse
order: left border to right, right border to right, left border to right without considering
`ignore_filetypes`, right border to right without considering `ignore_filetypes`.

Or you may not like these smart resizing, you can use the simple ones:

```lua
local resize = require('win.resizer').resize
local map_set = vim.keymap.set

-- How many lines or columns to resize, make sure it is a positive integer
local abs_delta = 3

-- Choose your favorite key mappings
-- Keys in border_to_key will try to increase the border
local border_to_key = {
    top = '<up>',
    bottom = '<down>',
    left = '<left>',
    right = '<right>',
}
-- Keys in border_to_reverse_key will try to decrease the border
local border_to_reverse_key = {
    top = '<s-up>',
    bottom = '<s-down>',
    left = '<s-left>',
    right = '<s-right>',
}
for _, border in pairs({ 'top', 'bottom', 'left', 'right' }) do
    local delta = abs_delta
    local desc = 'Increase ' .. border .. ' border'
    local desc_reverse = 'Decrease ' .. border .. ' border'
    map_set({ 'n' }, border_to_key[border], function()
        resize(0, border, delta, true)
    end, { desc = desc })
    map_set({ 'n' }, border_to_reverse_key[border], function()
        resize(0, border, -delta, true)
    end, { desc = desc_reverse })
end
```

## Command

There is a command `WinResizer` for resizing current window.

Examples:

```vim
" Increase the top border of the current window by 1
:WinResize top
" Decrease the top border of the current window by 1
:WinResize top -1
" Increase the right border of the current window by 1 without considering ignore_filetypes
:WinResize right 1 false
```
