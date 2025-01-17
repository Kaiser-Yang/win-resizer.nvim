--- @module 'win.resizer'

local win_resizer = {}

local utils = require('win.resizer.utils')
local default = require('win.resizer.config.default')
local config = {}

local function get_visible_windows()
    local windows = vim.api.nvim_tabpage_list_wins(0)
    local visible_windows = {}
    for _, win in ipairs(windows) do
        local win_config = vim.api.nvim_win_get_config(win)
        -- ignore invisible windows and floating windows
        if not utils.truthy(win_config.hide) and not utils.truthy(win_config.relative) then
            visible_windows[#visible_windows + 1] = win
        end
    end
    return visible_windows
end

--- Get the nearest neighbor window of the given window,
--- win is the window id
---
--- @param win number the window id
--- @param direction win.resizer.Border
--- @param respect_ignore_firetypes boolean
--- @return number|nil
local function get_nearest_neighbor(win, direction, respect_ignore_firetypes)
    local current_pos = vim.api.nvim_win_get_position(win)
    local current_row, current_col = current_pos[1], current_pos[2]
    local curretn_height = vim.api.nvim_win_get_height(win)
    local current_width = vim.api.nvim_win_get_width(win)
    local ignore_filetypes = utils.get_option(config.ignore_filetypes)

    local windows = {}
    for _, win_in_tab in ipairs(get_visible_windows()) do
        if win_in_tab == win or
            utils.truthy(respect_ignore_firetypes) and
            utils.truthy(ignore_filetypes) and
            vim.tbl_contains(ignore_filetypes, vim.bo[vim.api.nvim_win_get_buf(win_in_tab)].filetype) then
            goto continue
        end
        local pos = vim.api.nvim_win_get_position(win_in_tab)
        local row, col = pos[1], pos[2]
        local height = vim.api.nvim_win_get_height(win_in_tab)
        local width = vim.api.nvim_win_get_width(win_in_tab)
        if direction == 'left' and col + width < current_col or
            direction == 'right' and col > current_col + current_width or
            direction == 'top' and row + height < current_row or
            direction == 'bottom' and row > current_row + curretn_height then
            table.insert(windows, win_in_tab)
        end
        ::continue::
    end
    local neighbors = {}
    for _, win_in_direction in ipairs(windows) do
        local pos = vim.api.nvim_win_get_position(win_in_direction)
        local row, col = pos[1], pos[2]
        local height = vim.api.nvim_win_get_height(win_in_direction)
        local width = vim.api.nvim_win_get_width(win_in_direction)
        if direction == 'left' and (#neighbors == 0 or col + width > neighbors[1].col + neighbors[1].width) or
            direction == 'right' and (#neighbors == 0 or col < neighbors[1].col) or
            direction == 'top' and (#neighbors == 0 or row + height > neighbors[1].row + neighbors[1].height) or
            direction == 'bottom' and (#neighbors == 0 or row < neighbors[1].row) then
            neighbors = {
                {
                    id = win_in_direction,
                    row = row,
                    col = col,
                    width = width,
                    height = height,
                }
            }
        elseif direction == 'left' and #neighbors > 0 and col + width == neighbors[1].col + neighbors[1].width or
            direction == 'right' and #neighbors > 0 and col == neighbors[1].col or
            direction == 'top' and #neighbors > 0 and row + height == neighbors[1].row + neighbors[1].height or
            direction == 'bottom' and #neighbors > 0 and row == neighbors[1].row then
            table.insert(neighbors, {
                id = win_in_direction,
                row = row,
                col = col,
            })
        end
    end
    if #neighbors == 0 then
        return nil
    elseif #neighbors == 1 then
        return neighbors[1].id
    else
        local neighbor = nil
        for _, win_in_direction in ipairs(neighbors) do
            if (direction == 'left' or direction == 'right') and win_in_direction.row == current_row or
                (direction == 'top' or direction == 'bottom') and win_in_direction.col == current_col then
                neighbor = win_in_direction
                break
            end
        end
        if not neighbor then
            neighbor = neighbors[1]
        end
        return neighbor.id
    end
end

function win_resizer.setup(opts)
    config = vim.tbl_deep_extend('force', default, opts or {})
end

--- Resize window with border.
---
--- For example, resize(0, 'right', 5) will let the right border of current window
--- move 5 columns to the right if there is a visible window on the right.
--- resize(0, 'right', -5) will let the right border of current window move 5 columns
--- to the left if there is a visible window on the right. And win must be in the current tabpage.
---
--- When respect_ignore_firetypes is true, the window whose filetype is
--- in the ignore_filetypes will be treated as unvisible.
---
--- Return false if the window is not be resized.
---
--- @param win number the window id, 0 means the current window
--- @param border win.resizer.Border
--- @param delta? number default 1
--- @param respect_ignore_firetypes? boolean default true
--- @return boolean
function win_resizer:resize(win, border, delta, respect_ignore_firetypes)
    respect_ignore_firetypes = respect_ignore_firetypes == nil or respect_ignore_firetypes
    win = win == 0 and vim.api.nvim_get_current_win() or win
    local neighbor = get_nearest_neighbor(win, border, respect_ignore_firetypes)
    if not neighbor then
        return false
    end
    delta = delta or 1
    win = vim.fn.win_id2win(win)
    neighbor = vim.fn.win_id2win(neighbor)
    if border == 'right' then
        vim.fn.win_move_separator(win, delta)
    elseif border == 'bottom' then
        vim.fn.win_move_statusline(win, delta)
    elseif border == 'left' then
        vim.fn.win_move_separator(neighbor, -delta)
    elseif border == 'top' then
        vim.fn.win_move_statusline(neighbor, -delta)
    end
    return true
end

return win_resizer
