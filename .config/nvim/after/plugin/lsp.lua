local lsp_zero = require('lsp-zero')

local cmp = require("cmp")

cmp.setup {
    mapping = cmp.mapping.preset.insert {
        ["<Tab>"] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end,
        ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end,
        ["<CR>"] = cmp.mapping.confirm { select = true },
        ["<C-e>"] = cmp.mapping.abort(),
        ["<Esc>"] = cmp.mapping.close(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
    },
    sources = {
        { name = "nvim_lsp" }, -- For nvim-lsp
    },
    completion = {
        keyword_length = 1,
        completeopt = "menu,noselect",
    },
    formatting = {
        format = require("nvim-highlight-colors").format
    }
}

lsp_zero.set_preferences({
    sign_icons = {}
})


vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = false,
    float = true,
})

lsp_zero.on_attach(function(client, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr })
end)

require('mason').setup({})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false

vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        local jdtls = require('jdtls')
        local home = os.getenv("HOME")
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

        local config = {
            cmd = { '/usr/bin/jdtls' },
            root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew' }),
            workspace_folder = workspace_dir,
            capabilities = capabilities,
        }

        jdtls.start_or_attach(config)
    end,
})

require('mason-lspconfig').setup({
    ensure_installed = {
        'clangd',
        'lua_ls',
        'biome',
        'zls',
        'gopls',
        'omnisharp',
        'glsl_analyzer',
        'cmake',
    },
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({
                capabilities = capabilities
            })
        end,
    },
})
