# ⌨️ Neovim Keybindings Cheatsheet

> **Leader Key**: `<Space>`  
> **Config Flavor**: Neovim 0.12+ native package management (`vim.pack`) with Ivy Telescope theme & Catppuccin.

---

## 🚀 General & Essentials

| Shortcut | Mode | Description |
|----------|------|-------------|
| `jk` | Insert | Exit insert mode to Normal mode |
| `<leader>nh` | Normal | Clear search highlights (`:nohl`) |
| `<leader>+` | Normal | Increment number under cursor (`<C-a>`) |
| `<leader>-` | Normal | Decrement number under cursor (`<C-x>`) |
| `<space><space>x` | Normal | Reload / source current file (`:source %`) |
| `<space>x` | Normal | Execute current line in Lua |
| `<space>x` | Visual | Execute selected block in Lua |
| `<C-h>` | Insert / Cmd | Move cursor Left |
| `<C-j>` | Insert / Cmd | Move cursor Down |
| `<C-k>` | Insert / Cmd | Move cursor Up |
| `<C-l>` | Insert / Cmd | Move cursor Right |

---

## 🪟 Tmux & Window Splits Navigation

Seamless navigation across **Neovim window splits** and **Tmux panes** without needing a prefix:

| Shortcut | Mode | Action |
|----------|------|--------|
| `<C-h>` | Normal | Navigate to Left split / Tmux pane |
| `<C-j>` | Normal | Navigate to Down split / Tmux pane |
| `<C-k>` | Normal | Navigate to Up split / Tmux pane |
| `<C-l>` | Normal | Navigate to Right split / Tmux pane |
| `<C-\>` | Normal | Navigate to Previous split / Tmux pane |

### Window Splitting & Resizing
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>sv` | Normal | Split window **vertically** (`<C-w>v`) |
| `<leader>sh` | Normal | Split window **horizontally** (`<C-w>s`) |
| `<leader>se` | Normal | Make splits **equal width & height** (`<C-w>=`) |
| `<leader>sx` | Normal | **Close** current split window |

---

## 📑 Tabs & Bufferline

| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>to` | Normal | Open **new tab** (`:tabnew`) |
| `<leader>tx` | Normal | **Close** current tab (`:tabclose`) |
| `<leader>tn` | Normal | Go to **next tab** (`:tabn`) |
| `<leader>tp` | Normal | Go to **previous tab** (`:tabp`) |
| `<leader>tf` | Normal | Open current buffer in a **new tab** |

---

## 📁 File Explorer (`nvim-tree`)

| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>ee` | Normal | **Toggle** file explorer sidebar |
| `<leader>ef` | Normal | **Find and reveal** current file in explorer |
| `<leader>ec` | Normal | **Collapse** all explorer directories |
| `<leader>er` | Normal | **Refresh** file explorer view |

### Inside File Explorer:
| Key | Action |
|-----|--------|
| `<CR>` or `o` | Open file or expand/collapse folder |
| `a` | Create new file or folder (add `/` at end for folder) |
| `d` | Delete file/folder |
| `r` | Rename |
| `x` | Cut |
| `c` | Copy |
| `p` | Paste |
| `q` | Close file explorer |
| `g?` | Toggle keybindings cheat-sheet inside tree |

---

## 🔍 Fuzzy Finder (`Telescope`)

| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>ff` | Normal | Fuzzy find **files** in project |
| `<leader>fr` | Normal | Fuzzy find **recent / old files** |
| `<leader>fs` | Normal | **Live grep** with arguments (`live_grep_args`) |
| `<leader>fc` | Normal | Grep **word under cursor** |
| `<leader>fb` | Normal | List **active buffers** |

### Inside Telescope Popup:
| Shortcut | Action |
|----------|--------|
| `<C-j>` / `<C-k>` | Move selection down / up |
| `<C-q>` | Send selected items to quickfix list |
| `<CR>` | Open selected result |
| `<Esc>` | Close Telescope |

---

## 🧠 LSP & Code Intelligence (`Lspsaga` & `Neovim LSP`)

| Shortcut | Mode | Action |
|----------|------|--------|
| `gd` | Normal | **Peek definition** in floating preview |
| `gD` | Normal | **Go to definition** |
| `gr` | Normal | **LSP Finder** (references, definitions, implementations) |
| `K` | Normal | **Hover documentation** |
| `<leader>ca` | Normal | Show **code actions** |
| `<C-c>a` | Visual | Show **code actions** on selected block |
| `<leader>rn` | Normal | **Rename symbol** project-wide |
| `<leader>o` | Normal | Toggle code **outline / symbols** sidebar |
| `<leader>a` | Normal | **Auto-import** missing module (`lspimport`) |

### Diagnostics:
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>sl` | Normal | Show **line diagnostics** popup |
| `<leader>sc` | Normal | Show **cursor diagnostics** popup |
| `]e` | Normal | Jump to **next diagnostic** |
| `[e` | Normal | Jump to **previous diagnostic** |
| `]E` | Normal | Jump to **next ERROR** only |
| `[E` | Normal | Jump to **previous ERROR** only |

---

## 🌿 Git Integration (`Gitsigns`)

| Shortcut | Mode | Action |
|----------|------|--------|
| `]h` | Normal | Jump to **next hunk** |
| `[h` | Normal | Jump to **previous hunk** |
| `<leader>hs` | Normal/Visual | **Stage hunk** |
| `<leader>hr` | Normal/Visual | **Reset hunk** (discard changes) |
| `<leader>hS` | Normal | **Stage entire buffer** |
| `<leader>hR` | Normal | **Reset entire buffer** |
| `<leader>hu` | Normal | **Undo** last stage hunk |
| `<leader>hp` | Normal | **Preview hunk** inline diff popup |
| `<leader>hb` | Normal | Full line **git blame** popup |
| `<leader>hB` | Normal | Toggle **inline git blame** text |
| `<leader>hd` | Normal | **Diff split** against git index |
| `<leader>hD` | Normal | **Diff split** against `HEAD~` |
| `ih` | Text Object | Select hunk (e.g. `dih` delete hunk, `cih` change hunk) |

---

## 🧹 Formatting & Linting

| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>mp` | Normal / Visual | **Format** buffer or selected range (`conform.nvim`) |
| `<leader>l` | Normal | Trigger **linting** on current file (`nvim-lint`) |

*Formatting is also performed automatically on save for configured filetypes.*

---

## ✏️ Editing, Substitution & Comments

### Substitute (`substitute.nvim`)
| Shortcut | Mode | Action |
|----------|------|--------|
| `s{motion}` | Normal | Replace text with clipboard register (e.g. `siw` replaces word) |
| `ss` | Normal | Replace entire current line |
| `S` | Normal | Replace to end of line |
| `s` | Visual | Replace highlighted selection |

### Comments (`Comment.nvim`)
| Shortcut | Mode | Action |
|----------|------|--------|
| `gcc` | Normal | Toggle line comment |
| `gbc` | Normal | Toggle block comment |
| `gc` | Visual | Toggle comment on selection |
| `gb` | Visual | Toggle block comment on selection |

---

## ⚡ Autocompletion (`nvim-cmp`)

| Shortcut | Mode | Action |
|----------|------|--------|
| `<C-j>` | Insert | Select **next item** in popup |
| `<C-k>` | Insert | Select **previous item** in popup |
| `<C-Space>` | Insert | Trigger completion menu manually |
| `<C-e>` | Insert | Close completion popup |
| `<CR>` | Insert | Confirm and insert selected completion |
| `<C-f>` | Insert | Scroll documentation **forward** |
| `<C-b>` | Insert | Scroll documentation **backward** |

---

## 📦 Package Management (`vim.pack`)

| Command | Description |
|---------|-------------|
| `:PackUpdate` | Check and update all installed plugins interactively |
| `:PackUpdate!` | Force update all plugins without prompt |
