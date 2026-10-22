require("lspsaga").setup({
	finder = {
		theme = "default",
	},
	ui = {
		border = "rounded",
	},
})

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- LSP Finder
keymap("n", "gr", "<Cmd>Lspsaga finder<CR>", opts)

-- Hover documentation
keymap("n", "K", "<Cmd>Lspsaga hover_doc<CR>", opts)

-- Code Actions
keymap("n", "<leader>ca", "<Cmd>Lspsaga code_action<CR>", opts)
keymap("v", "<C-c>a", "<Cmd>Lspsaga code_action<CR>", opts)

-- Rename symbol
keymap("n", "<leader>rn", "<Cmd>Lspsaga rename<CR>", opts)

-- Definitions
keymap("n", "gd", "<Cmd>Lspsaga peek_definition<CR>", opts)
keymap("n", "gD", "<Cmd>Lspsaga goto_definition<CR>", opts)

-- Diagnostics
keymap("n", "<leader>sl", "<Cmd>Lspsaga show_line_diagnostics<CR>", opts)
keymap("n", "<leader>sc", "<Cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
keymap("n", "[e", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
keymap("n", "]e", "<Cmd>Lspsaga diagnostic_jump_next<CR>", opts)

-- Error jumps using Neovim 0.11/0.12 native diagnostic jump API
keymap("n", "[E", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
end, opts)
keymap("n", "]E", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
end, opts)

-- Outline
keymap("n", "<leader>o", "<Cmd>Lspsaga outline<CR>", opts)
