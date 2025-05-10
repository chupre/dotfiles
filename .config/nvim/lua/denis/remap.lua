vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>")
vim.keymap.set("n", "<leader>pr", "<CMD>Oil .<CR>")
vim.keymap.set("n", "<leader>po", "<CMD>Oil --float<CR>")
vim.keymap.set("n", "<leader>pt", "<CMD>Themery<CR>")
vim.keymap.set("n", "<leader>ptr", "<CMD>TransparentToggle<CR>")
vim.keymap.set("n", "<leader>n", "<CMD>noh<CR>")
vim.keymap.set({"n", "v"}, "<leader>l", function ()
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

