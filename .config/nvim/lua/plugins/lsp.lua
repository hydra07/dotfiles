return {
	{
		"williamboman/mason.nvim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = "Mason",
		opts = { ui = { border = "single" } },
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				event = "VeryLazy",
				opts = {
					ensure_installed = {
						"stylua",
						"prettierd",
						"eslint_d",
						"black",
						"prettier",
						"shellcheck",
						"shfmt",
					},
				},
			},
		},
		opts = {
			ensure_installed = {
				"bashls",
				"fish_lsp",
				"powershell_es",
				"vtsls",
				"pyright",
				"rust_analyzer",
				"gopls",
				"lua_ls",
				"tailwindcss",
				"eslint",
			},
			automatic_installation = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "saghen/blink.cmp" },
		config = function()
			local servers = {
				"eslint",
				"vtsls",
				"pyright",
				"rust_analyzer",
				"gopls",
				"lua_ls",
				"tailwindcss",
				"bashls",
				"fish_lsp",
				"powershell_es",
			}
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			for _, server in ipairs(servers) do
				local config = { capabilities = capabilities }
				if server == "lua_ls" then
					config.settings = { Lua = { diagnostics = { globals = { "vim" } } } }
				-- PS
				elseif server == "powershell_es" then
					config.settings = {
						powershell = {
							scriptAnalysis = { enable = true, settingsPath = "" },
							codeFormatting = { Preset = "OTBS" }, -- Hoặc "Microsoft" tùy style bạn thích
						},
					}
					-- Neovide trên Windows đôi khi cần chỉ định rõ đường dẫn bundle nếu Mason không tự nhận
					config.bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services"
				-- ESLINT
				elseif server == "eslint" then
					config.settings = {
						workingDirectories = { mode = "auto" },
					}
				-- TYPESCRIPT
				elseif server == "vtsls" then
					config.settings = {
						typescript = {
							autoImports = true,
							inlayHints = {
								variableTypes = { enabled = true },
								parameterNames = { enabled = "literals" },
								functionLikeReturnTypes = { enabled = true },
							},
						},
					}
				-- RUST
				elseif server == "rust_analyzer" then
					config.settings = {
						["rust-analyzer"] = {
							checkOnSave = { command = "clippy" },
							inlayHints = {
								chainingHints = { enabled = true },
								closingBraceHints = { enabled = true, minLines = 25 },
								parameterHints = { enabled = true },
								typeHints = { enabled = true },
							},
						},
					}
				-- GO
				elseif server == "gopls" then
					config.settings = {
						gopls = {
							completeUnimported = true,
							staticcheck = true,
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					}
				end
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end
			vim.keymap.set("n", ";h", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			end, { desc = "LSP: Toggle Inlay Hints" })
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = "single" })
			vim.diagnostic.config({
				float = { border = "single" },
				virtual_text = true, -- QUAN TRỌNG: set thành true để hiện inline
				signs = true, -- Hiện icon bên lề trái (gutter)
				underline = true, -- Gạch chân dưới chỗ lỗi
				update_in_insert = false, -- Tắt update khi đang gõ để đỡ rối mắt
				severity_sort = true, -- Ưu tiên hiện lỗi nặng trước
			})
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.supports_method("textDocument/documentHighlight") then
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = args.buf,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = args.buf,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})
		end,
	},
}
