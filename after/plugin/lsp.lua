local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.ensure_installed({
	'tsserver',
	'eslint',
	'sumneko_lua',
	'rust_analyzer',
})

lsp.configure('sumneko_lua', {
	settings = {
		telemetry = {
			enable = false
		}
	}
})

local cmp = require('cmp')
local cmp_mappings = lsp.defaults.cmp_mappings({
	["<C-Space>"] = cmp.mapping.complete(),
	["<Enter>"] = nil
})

lsp.setup_nvim_cmp({ mapping = cmp_mappings })

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
end)

-- Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()
