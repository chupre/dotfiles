vim.g.mapleader = " "
vim.keymap.set("n", "<leader>n", "<CMD>noh<CR>")
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<leader>gr', function()
    builtin.lsp_references()
end, { desc = 'LSP References' })
vim.keymap.set('n', '<leader>gf', function()
    builtin.lsp_document_symbols()
end, { desc = 'LSP References' })

vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>n", "<CMD>noh<CR>")
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<leader>gr', function()
    builtin.lsp_references()
end, { desc = 'LSP References' })
vim.keymap.set('n', '<leader>gf', function()
    builtin.lsp_document_symbols()
end, { desc = 'LSP References' })

vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Wq", "wq", {})

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
