local dev_plugin_path = "/home/rahulj/trioptima/codebase/src/labdays/nvim_example_plugin/present.nvim"
if (vim.uv or vim.loop).fs_stat(dev_plugin_path) then
	vim.opt.rtp:append(dev_plugin_path)
	-- require("present")
end
