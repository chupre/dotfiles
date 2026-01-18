-- Save this as lua/floating_cmd.lua
local M = {}
local history = {}

local function save_history(cmd)
    -- Only save non-empty commands
    if cmd ~= "" then
        table.insert(history, 1, cmd) -- insert at the start
    end
end

local function delete_history(index)
    table.remove(history, index)
end

function M.open()
    -- Buffer for the floating window
    local buf = vim.api.nvim_create_buf(false, true)
    
    -- Window options
    local width = math.floor(vim.o.columns * 0.5)
    local height = 1
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'single'
    })

    -- Insert prompt
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    -- Keymaps for the floating window
    vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', '<Cmd>lua require"floating_cmd".execute('..buf..','..win..')<CR>', {silent = true, noremap = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<Cmd>bd!<CR>', {silent = true, noremap = true})
end

function M.execute(buf, win)
    local cmd = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
    save_history(cmd)
    vim.api.nvim_win_close(win, true)
    vim.cmd(cmd)
end

function M.show_history()
    print("Command History:")
    for i, cmd in ipairs(history) do
        print(i .. ": " .. cmd)
    end
end

function M.delete_history_entry(index)
    delete_history(index)
end

return M

