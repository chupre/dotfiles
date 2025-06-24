require('telescope').setup {
    extensions = {
        media_files = {
            filetypes = {"png", "jpg", "pdf", "jpeg"},
            find_cmd = "rg"
        }
    }
}
require('telescope').load_extension('media_files')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set("n", "<leader>pm", "<CMD>Telescope media_files<CR>")
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
