vim.pack.add({
    { src = "https://github.com/mason-org/mason.nvim" },
})
require("mason").setup({})

vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
}

vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" },
})

vim.pack.add({
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
})

vim.pack.add({
    { src = "https://github.com/windwp/nvim-autopairs" },
})
require("nvim-autopairs").setup({})

