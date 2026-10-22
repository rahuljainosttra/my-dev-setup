local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

mason_lspconfig.setup({
	ensure_installed = {
		"lua_ls",
		"gopls",
		"pyright",
		"clojure_lsp",
	},
})

mason_tool_installer.setup({
	ensure_installed = {
		"prettier",
		"gofumpt",
		"stylua",
		"isort",
		"black",
		"ruff",
	},
})
