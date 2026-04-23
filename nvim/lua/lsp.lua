vim.lsp.enable({
    "lua_ls",
    "ols",
})

vim.lsp.config("ols", {
	init_options = {
		checker_args = "-strict-style",
		collections = {
			{ name = "odin-sr", path = vim.fn.expand('$HOME/code/odin_sr/src') }
		},
	},
})

