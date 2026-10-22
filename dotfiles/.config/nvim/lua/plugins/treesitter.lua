require("nvim-treesitter").setup()
require("nvim-treesitter").install({ "go", "javascript", "clojure", "ecma", "jsx" })

local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
