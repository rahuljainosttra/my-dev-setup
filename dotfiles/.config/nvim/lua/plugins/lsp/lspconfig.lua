-- Diagnostic configuration (Neovim 0.12 native)
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
})

-- Set completion capabilities globally for all servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", {
	capabilities = capabilities,
})

-- Enable installed servers
local servers = { "lua_ls", "gopls", "pyright", "clojure_lsp" }
for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end
