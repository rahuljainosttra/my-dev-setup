### Installation (Neovim 0.12 with asdf)

1. Clone repository:
   ```bash
   git clone https://github.com/rahuljainosttra/nvim.git ~/my-nvim-config
   ```
2. Run the setup script:
   ```bash
   cd ~/my-nvim-config
   ./scripts/setup.sh
   ```
   The script will:
   - Verify or install `asdf`
   - Add the `neovim` asdf plugin and install `0.12.6` (prebuilt binary)
   - Link `~/.config/nvim` to the config directory (with automatic backup if an existing config is found)
   - Verify build dependencies (`make`, `gcc`, `ripgrep`, `fd`, `node`, `python3`)
   - Bootstrap all plugins via native `vim.pack` and compile native extensions (`libfzf.so`, `jsregexp`)
3. Launch Neovim:
   ```bash
   nvim
   ```

### Legacy Installation


### frontend

* add file `.lsp/config.edn` relative from project root
* with following content 
```
{
:source-paths #{"src" "test"} 
}

```

### Packer snapshot

cp stable-09-18 /home/rahulj/.cache/nvim/packer.nvim/

https://dev.to/vonheikemen/packernvim-how-to-recover-from-a-bad-plugin-update-2813
