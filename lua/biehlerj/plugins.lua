return {
	-- the colorscheme should be available when starting Neovim
	{
		'catppuccin/nvim',
		lazy = false,    -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			-- load the colorscheme here
			vim.cmd([[colorscheme catppuccin]])
		end,
	},
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function ()
			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
			vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
			vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
			vim.keymap.set('n', '<leader>ps', function()
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)
		end
	},
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function ()
			local configs = require('nvim-treesitter.configs')

			configs.setup({
				ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'rust', 'javascript', 'typescript', 'html', 'go' },
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
			})
		end
	},
	{
		'ThePrimeagen/harpoon',
		config = function ()
			local mark = require("harpoon.mark")
			local ui = require("harpoon.ui")

			vim.keymap.set("n", "<leader>a", mark.add_file)
			vim.keymap.set("n", "<leader>qm", ui.toggle_quick_menu)

			vim.keymap.set("n", "<leader>h", function() ui.nav_file(1) end)
			vim.keymap.set("n", "<leader>t", function() ui.nav_file(2) end)
			vim.keymap.set("n", "<leader>m", function() ui.nav_file(3) end)
			vim.keymap.set("n", "<leader>q", function() ui.nav_file(4) end)
		end
	},
	{
		'mbbill/undotree',
		config = function ()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end
	},
	{
		'tpope/vim-fugitive',
		config = function ()
			vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
		end
	},
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v4.x',
		lazy = true,
		config = false,
	},
	{
		'williamboman/mason.nvim',
		lazy = false,
		config = true,
	},

	-- Autocompletion
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			{'L3MON4D3/LuaSnip'},
			{
				'windwp/nvim-autopairs',
				event = "InsertEnter",
				config = true
				-- use opts = {} for passing setup options
				-- this is equivalent to setup({}) function
			}
		},
		config = function()
			local luasnip = require('luasnip')
			local cmp_autopairs = require('nvim-autopairs.completion.cmp')
			local cmp = require('cmp')

			cmp.event:on(
				'confirm_done',
				cmp_autopairs.on_confirm_done()
			)
			cmp.setup({
				sources = {
					{name = 'nvim_lsp'},
				},
				mapping = cmp.mapping.preset.insert({
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-u>'] = cmp.mapping.scroll_docs(-4),
					['<C-d>'] = cmp.mapping.scroll_docs(4),
					['<CR>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							if luasnip.expandable() then
								luasnip.expand()
							else
								cmp.confirm({
									select = true,
								})
							end
						else
							fallback()
						end
					end),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.locally_jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
			})
		end
	},

	-- LSP
	{
		'neovim/nvim-lspconfig',
		cmd = {'LspInfo', 'LspInstall', 'LspStart'},
		event = {'BufReadPre', 'BufNewFile'},
		dependencies = {
			{'hrsh7th/cmp-nvim-lsp'},
			{'williamboman/mason.nvim'},
			{'williamboman/mason-lspconfig.nvim'},
		},
		config = function()
			local lsp_zero = require('lsp-zero')

			-- lsp_attach is where you enable features that only work
			-- if there is a language server active in the file
			local lsp_attach = function(client, bufnr)
				local opts = {buffer = bufnr}

				vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
				vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
				vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
				vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
				vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
				vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
				vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
				vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
				vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
				vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
			end

			lsp_zero.extend_lspconfig({
				sign_text = true,
				lsp_attach = lsp_attach,
				capabilities = require('cmp_nvim_lsp').default_capabilities()
			})

			require('mason-lspconfig').setup({
				ensure_installed = {
					'eslint',
					'lua_ls',
					'rust_analyzer',
				},
				handlers = {
					-- this first function is the 'default handler'
					-- it applies to every language server without a 'custom handler'
					function(server_name)
						require('lspconfig')[server_name].setup({})
					end,
				}
			})
			require'lspconfig'.lua_ls.setup {
				on_init = function(client)
					local path = client.workspace_folders[1].name
					if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
						return
					end

					client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
						runtime = {
							-- Tell the language server which version of Lua you're using
							-- (most likely LuaJIT in the case of Neovim)
							version = 'LuaJIT'
						},
						-- Make the server aware of Neovim runtime files
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME
								-- Depending on the usage, you might want to add additional paths here.
								-- "${3rd}/luv/library"
								-- "${3rd}/busted/library",
							}
							-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
							-- library = vim.api.nvim_get_runtime_file("", true)
						}
					})
				end,
				settings = {
					Lua = {}
				}
			}
		end
	},
	{ 'mfussenegger/nvim-dap' },
	{ 'jayp0521/mason-nvim-dap.nvim' },
	{ 'jose-elias-alvarez/null-ls.nvim' },
	{ 'jayp0521/mason-null-ls.nvim' },
	{ 'RubixDev/mason-update-all' },
	{ 'lewis6991/gitsigns.nvim' },
	{
		"nvim-neorg/neorg",
		-- lazy-load on filetype
		ft = "norg",
		-- options for neorg. This will automatically call `require("neorg").setup(opts)`
		opts = {
			load = {
				["core.defaults"] = {},
			},
		},
	},
}
