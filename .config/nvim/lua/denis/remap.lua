vim.api.nvim_create_autocmd("User", {
    pattern = "OilEnter",
    callback = vim.schedule_wrap(function(args)
        local oil = require("oil")
        if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
            vim.opt.splitright = true
            oil.open_preview()
        end
    end),
})

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>")
vim.keymap.set("n", "<leader>pr", "<CMD>Oil .<CR>")
vim.keymap.set("n", "<leader>po", "<CMD>Oil --float<CR>")
vim.keymap.set("n", "<leader>pt", "<CMD>Themery<CR>")
vim.keymap.set("n", "<leader>ptr", "<CMD>TransparentToggle<CR>")
vim.keymap.set("n", "<leader>n", "<CMD>noh<CR>")
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>gr', function()
  require('telescope.builtin').lsp_references()
end, { desc = 'LSP References' })
vim.keymap.set({ "n", "v" }, "<leader>l", function()
    require("conform").format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
    })
end)


vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
