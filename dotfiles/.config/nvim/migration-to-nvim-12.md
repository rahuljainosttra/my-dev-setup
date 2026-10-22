# Neovim 0.11 to 0.12 Migration Guide

This document outlines the analysis, prerequisites, and required modifications to upgrade this configuration from Neovim 0.11 (`v0.11.4`) to Neovim 0.12 (`v0.12.x`).

---

## 1. Executive Summary & Status

| Component | Current State | Target State (Nvim 0.12) | Action Required |
| :--- | :--- | :--- | :--- |
| **`tree-sitter-cli`** | `0.25.10` (asdf) | `>= 0.26.1` | **Upgrade required** before updating parsers |
| **`nvim-treesitter`** | `branch = "main"` | `branch = "main"` | Add augroup, remove redundant path overrides |
| **Lazy bootstrap** | Uses `vim.loop` | Uses `vim.uv` | Update in `init.lua` |
| **LSP Setup** | Loops `get_installed_servers()` | Native `vim.lsp.config('*', ...)` + `vim.lsp.enable()` | Refactor `lua/plugins/lsp/lspconfig.lua` |
| **`lspsaga.nvim`** | Pinned to `legacy` | Upstream `main` | Remove legacy tag; adopt `vim.diagnostic.jump` |
| **`conform.nvim`** | `lsp_fallback = false` | `lsp_format = "never"` | Fix deprecation warning |
| **`lua/lazy.lua`** | Duplicate code | Deleted | Clean up unused file |

---

## 2. External Dependencies

### Upgrade `tree-sitter-cli` to `>= 0.26.1`
The rewritten `nvim-treesitter` (`main` branch) requires `tree-sitter-cli >= 0.26.1` for parser compilation and health checks.

Check current version:
```bash
tree-sitter --version
# tree-sitter 0.25.10
```

Upgrade via `asdf` (or your preferred package manager):
```bash
asdf install tree-sitter 0.26.1
asdf global tree-sitter 0.26.1
```

---

## 3. Configuration Changes

### A. `init.lua` — Migrate `vim.loop` to `vim.uv`
In Neovim 0.10+, `vim.loop` was aliased to `vim.uv` and is progressively deprecated.

**File:** `init.lua`
```lua
-- Replace line 3:
-- if not vim.loop.fs_stat(lazypath) then
if not (vim.uv or vim.loop).fs_stat(lazypath) then
```

*(Optional)* To suppress healthcheck warnings about Luarocks if you do not use luarocks packages, add `rocks = { enabled = false }` to your Lazy setup in `init.lua`:
```lua
require("lazy").setup({
	{ import = "plugins" },
	{ import = "plugins.lsp" },
}, {
	rocks = {
		enabled = false,
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})
```

---

### B. `lua/plugins/treesitter.lua` — Treesitter Rewrite Configuration
On the `main` branch, `nvim-treesitter` no longer manages highlighting and folding internally; it delegates them to Neovim's native engine (`vim.treesitter.start()` and `vim.treesitter.foldexpr()`). In Neovim 0.12, `vim.treesitter.get_parser()` safely returns `nil` when no parser exists.

**File:** `lua/plugins/treesitter.lua`
```lua
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = function()
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
	end,
}
```

---

### C. `lua/plugins/lsp/lspconfig.lua` — Modern Native LSP Configuration
Neovim 0.12 natively supports global configuration via wildcard `*` with `vim.lsp.config('*', ...)`. Additionally, legacy `sign_define` is removed in 0.12, meaning all diagnostic signs must be configured through `vim.diagnostic.config`.

**File:** `lua/plugins/lsp/lspconfig.lua`
```lua
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
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
	end,
}
```

---

### D. `lua/plugins/lspsaga.lua` — Version and Diagnostic Navigation Fixes
1. Remove `version = "legacy"`: The legacy tag is outdated and incompatible with internal LSP refactors in Neovim 0.12.
2. `vim.diagnostic.goto_prev` / `goto_next` are deprecated in favor of `vim.diagnostic.jump({ count = -1 })` and `vim.diagnostic.jump({ count = 1 })`.

**File:** `lua/plugins/lspsaga.lua`
```lua
return {
	"nvimdev/lspsaga.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
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
	end,
}
```

---

### E. `lua/plugins/formating.lua` — Conform Option Deprecation
In `conform.nvim`, `lsp_fallback` is deprecated and superseded by `lsp_format`.

**File:** `lua/plugins/formating.lua`
Update `format_on_save` and the `<leader>mp` keymap:
```lua
-- In conform.setup:
format_on_save = {
	lsp_format = "never", -- Replaces lsp_fallback = false
	async = false,
	timeout_ms = 1000,
},

-- In format keymap:
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
	conform.format({
		lsp_format = "never", -- Replaces lsp_fallback = false
		async = false,
		timeout_ms = 1000,
	})
end, { desc = "Format file or range (in visual mode)" })
```

---

### F. Remove Redundant `lua/lazy.lua`
The file `lua/lazy.lua` contains duplicate bootstrap and setup logic from an earlier configuration revision and is never loaded by `init.lua`.

Remove it:
```bash
rm lua/lazy.lua
```

---

## 4. Step-by-Step Migration Checklist

- [ ] **Step 1:** Upgrade `tree-sitter` CLI to `>= 0.26.1` via `asdf`.
- [ ] **Step 2:** Apply changes to `init.lua`, `lua/plugins/treesitter.lua`, `lua/plugins/lsp/lspconfig.lua`, `lua/plugins/lspsaga.lua`, and `lua/plugins/formating.lua`.
- [ ] **Step 3:** Remove redundant `lua/lazy.lua`.
- [ ] **Step 4:** Switch your active Neovim binary to 0.12.
- [ ] **Step 5:** Synchronize plugins in Neovim:
  ```vim
  :Lazy sync
  ```
- [ ] **Step 6:** Recompile/update Tree-sitter parsers:
  ```vim
  :TSUpdate
  ```
- [ ] **Step 7:** Verify health status:
  ```vim
  :checkhealth
  :checkhealth vim.lsp
  :checkhealth nvim-treesitter
  ```
