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

vim.pack.add({
    { src = "https://github.com/blazkowolf/gruber-darker.nvim" }
})

vim.pack.add({
    { src = "https://github.com/xiyaowong/transparent.nvim" }
})

vim.pack.add({
  {
    src = 'https://github.com/JavaHello/spring-boot.nvim',
    version = '218c0c26c14d99feca778e4d13f5ec3e8b1b60f0',
  },
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/mfussenegger/nvim-dap',

  'https://github.com/nvim-java/nvim-java',
})

require('java').setup()
vim.lsp.enable('jdtls')
