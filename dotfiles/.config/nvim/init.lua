-- Step 1: Core configuration (options, keymaps)
require("core")

-- Step 2: Native packages & plugin setup via vim.pack
require("pack")

-- Step 3: Provider and environment configurations
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.env.GOFLAGS = "-tags=integration,unit"
