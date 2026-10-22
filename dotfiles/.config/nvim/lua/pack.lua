local specs = {
	-- Utilities & Dependencies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/christoomey/vim-tmux-navigator",

	-- UI & Theme
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/stevearc/dressing.nvim",
	"https://github.com/lukas-reineke/indent-blankline.nvim",

	-- Navigation & Explorer
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/folke/which-key.nvim",
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "v0.1.9" },
	"https://github.com/nvim-telescope/telescope-live-grep-args.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

	-- Editing & Text Navigation
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/numToStr/Comment.nvim",
	"https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
	"https://github.com/gbprod/substitute.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",

	-- Formatting & Linting
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",

	-- LSP
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvimdev/lspsaga.nvim",
	"https://github.com/stevanmilic/nvim-lspimport",

	-- Completion & Snippets
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/saadparwaiz1/cmp_luasnip",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/onsails/lspkind.nvim",
}

-- Build hooks for compiled plugins
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("PackHooks", { clear = true }),
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if kind == "install" or kind == "update" then
			if name == "telescope-fzf-native.nvim" then
				vim.system({ "make" }, { cwd = ev.data.path }):wait()
			elseif name == "LuaSnip" then
				vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path }):wait()
			end
		end
	end,
})

-- Add packages via Neovim 0.12 native package manager
vim.pack.add(specs, { confirm = false })

-- Auto-compile telescope-fzf-native if libfzf.so is missing
local fzf_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/telescope-fzf-native.nvim"
local fzf_lib = fzf_dir .. "/build/libfzf.so"
if (vim.uv or vim.loop).fs_stat(fzf_dir) and not (vim.uv or vim.loop).fs_stat(fzf_lib) then
	vim.system({ "make" }, { cwd = fzf_dir }):wait()
end

-- Load local / dev plugins
require("plugins.dev")

-- Load plugin configurations in proper dependency order
require("plugins.colorscheme")
require("plugins.which-key")
require("plugins.treesitter")
require("plugins.nvim-tree")
require("plugins.bufferline")
require("plugins.lualine")
require("plugins.gitsigns")
require("plugins.substitute")
require("plugins.indent-blankline")
require("plugins.comment")
require("plugins.telescope")
require("plugins.dressing")
require("plugins.formating")
require("plugins.linting")

-- LSP & Completion
require("plugins.lsp.mason")
require("plugins.nvim-cmp")
require("plugins.autopairs")
require("plugins.lsp.lspconfig")
require("plugins.lspsaga")
require("plugins.lspimport")

-- User command to manually update plugins
vim.api.nvim_create_user_command("PackUpdate", function(opts)
	local force = opts.bang
	vim.pack.update(nil, { force = force })
end, { bang = true, desc = "Update plugins with vim.pack (! to force without prompt)" })

-- Auto-update plugins on startup
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("PackAutoUpdate", { clear = true }),
	callback = function()
		-- Skip in headless mode, diff mode, or when explicitly disabled
		if #vim.api.nvim_list_uis() == 0 or vim.o.diff or vim.g.pack_auto_update == false then
			return
		end
		vim.schedule(function()
			local force = vim.g.pack_auto_update_force or false
			vim.pack.update(nil, { force = force })
		end)
	end,
})
