-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("n", "<space><space>x", "<cmd>source %<CR>", { desc = "re-run current file" })
keymap.set("n", "<space>x", ":.lua<CR>", { desc = "runs current line in lua" })
keymap.set("v", "<space>x", ":lua<CR>", { desc = "runs visual selected block in lua" })

-- Navigate in insert and command mode with Ctrl + hjkl
keymap.set({ "i", "c" }, "<C-h>", "<Left>", { noremap = true, silent = true, desc = "Move Left" })
keymap.set({ "i", "c" }, "<C-j>", "<Down>", { noremap = true, silent = true, desc = "Move Down" })
keymap.set({ "i", "c" }, "<C-k>", "<Up>", { noremap = true, silent = true, desc = "Move Up" })
keymap.set({ "i", "c" }, "<C-l>", "<Right>", { noremap = true, silent = true, desc = "Move Right" })
