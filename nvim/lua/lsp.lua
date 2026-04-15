vim.lsp.enable({
    "lua_ls",
    "ols",
})

vim.lsp.config("ols", {
    init_options = {
        collections = {
            { name = "odin-sr", path = vim.fn.expand('$HOME/code/odin-render/src') }
        }
    } 
})
