local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	-- lsp
	{"neovim/nvim-lspconfig"},

	-- autocomplete
	{"hrsh7th/nvim-cmp"},
	{"hrsh7th/cmp-nvim-lsp"},
	{"hrsh7th/cmp-buffer"},
	{"hrsh7th/cmp-path"},
	{"hrsh7th/cmp-cmdline"},
	{"L3MON4D3/LuaSnip"},
	{"saadparwaiz1/cmp_luasnip"},
})

local lspconfig = require("lspconfig")
-- Go LSP setup
lspconfig.gopls.setup({
  settings = {
    gopls = {
      analyses = {
	unusedparams = true, 
      },
      staticcheck = true, 
      gofumpt = true, 
    },
  },
})

lspconfig.pylsp.setup({})



-- autoformat on save go lsp 
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = {"*.go", "*.py"},
	callback = function() 
		local params = vim.lsp.util.make_range_params()
		params.context = {only = {"source.organizeImports"}}
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do 
				if r.edit then 
					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(r.edit,enc)
				end
			end
		end
		vim.lsp.buf.format({async = false})
		end
})

-- autocomplete config
local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true}),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" }, 
		{ name = "buffer" }, 
		{ name = "path" },
	}),
})


-- set relative line numbers
vim.wo.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

require("lsp_lines").setup()
vim.diagnostic.config({
	virtual_text = false,
})

