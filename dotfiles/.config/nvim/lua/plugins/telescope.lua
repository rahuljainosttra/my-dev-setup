local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous, -- move to prev result
				["<C-j>"] = actions.move_selection_next, -- move to next result
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
			},
		},
		layout_strategy = "vertical",
		theme = "ivy",
		layout_config = {
			preview_cutoff = 0,
		},
	},
})

telescope.load_extension("fzf")
telescope.load_extension("live_grep_args")

-- set keymaps
local keymap = vim.keymap -- for conciseness

keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
keymap.set(
	"n",
	"<leader>fs",
	require("telescope").extensions.live_grep_args.live_grep_args,
	{ desc = "Find string in cwd" }
)
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
keymap.set(
	"n",
	"<leader>fb",
	"<cmd>Telescope buffers<cr>",
	{ desc = "list open buffers in current neovim instance" }
)
