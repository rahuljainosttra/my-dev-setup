# 🪟 Tmux Keybindings Cheatsheet

> **Default Prefix Key**: `Ctrl-b` (referred to as `<Prefix>`)  
> **Theme**: `powerline/default/cyan`  
> **Status**: Mouse mode enabled (`set -g mouse on`), Vi mode enabled (`mode-keys vi`).

---

## ⚡ Essential Controls

| Shortcut | Action |
|----------|--------|
| `<Prefix> r` | **Reload** `~/.tmux.conf` configuration file |
| `<Prefix> d` | **Detach** from session (keeps session running in background) |
| `<Prefix> :` | Open Tmux **command prompt** |
| `<Prefix> ?` | List all active Tmux keybindings |

---

## ✂️ Panes & Splitting

All new splits inherit the **current working directory** of the active pane.

| Shortcut | Action |
|----------|--------|
| `<Prefix> \|` | Split pane **vertically** (side-by-side) |
| `<Prefix> -` | Split pane **horizontally** (top / bottom) |
| `<Prefix> x` | **Close** current pane (prompts for confirmation) |
| `<Prefix> z` | **Zoom / Maximize** pane (press again to restore) |
| `<Prefix> q` | Display **pane numbers** (press number to jump to pane) |
| `<Prefix> !` | Break active pane out into a **new separate window** |

---

## 🧭 Pane Navigation (`vim-tmux-navigator`)

Navigate seamlessly between **Tmux panes** and **Neovim splits** without pressing `<Prefix>`:

| Shortcut | Action |
|----------|--------|
| `<C-h>` | Move to **Left** pane / split |
| `<C-j>` | Move to **Down** pane / split |
| `<C-k>` | Move to **Up** pane / split |
| `<C-l>` | Move to **Right** pane / split |
| `<C-\>` | Move to **Previous** pane / split |

---

## 📏 Pane Resizing

These shortcuts are **repeatable** (you can tap the direction key multiple times after `<Prefix>`):

| Shortcut | Action |
|----------|--------|
| `<Prefix> h` | Resize pane **Left** by 5 cells |
| `<Prefix> j` | Resize pane **Down** by 5 cells |
| `<Prefix> k` | Resize pane **Up** by 5 cells |
| `<Prefix> l` | Resize pane **Right** by 5 cells |

---

## 📑 Windows (Tabs)

| Shortcut | Action |
|----------|--------|
| `<Prefix> c` | Create **new window** (opens in current pane directory) |
| `<Prefix> ,` | **Rename** current window |
| `<Prefix> &` | **Kill** current window |
| `<Prefix> n` | Switch to **next window** |
| `<Prefix> p` | Switch to **previous window** |
| `<Prefix> 0` .. `9` | Select window by **number** |
| `<Prefix> w` | Open interactive **tree view** of all windows & sessions |

---

## 📋 Vi Copy Mode & Clipboard

Copy mode uses standard Vi keys with mouse integration.

| Shortcut | Action |
|----------|--------|
| `<Prefix> [` | **Enter copy mode** |
| `v` *(in copy mode)* | Begin visual selection |
| `y` *(in copy mode)* | Copy selection to Tmux buffer and system clipboard (`tmux-yank`) |
| `q` or `<Esc>` | Exit copy mode |
| `<Prefix> ]` | **Paste** current Tmux buffer |
| **Mouse Drag** | Select text with mouse (does **not** auto-exit copy mode) |
| **Mouse Scroll** | Scroll up to enter copy mode and inspect history |

---

## 🖥️ Session Management

| Shortcut | Action |
|----------|--------|
| `<Prefix> s` | Interactive session switcher list |
| `<Prefix> $` | **Rename** current session |

### CLI Session Commands:
```bash
tmux new -s <session_name>        # Start a new named session
tmux ls                           # List all running sessions
tmux attach -t <session_name>     # Re-attach to a running session
tmux kill-session -t <name>       # Terminate a session
```

---

## 🔌 Plugin Manager (`TPM`)

| Shortcut | Action |
|----------|--------|
| `<Prefix> I` *(Shift+i)* | **Install** configured plugins |
| `<Prefix> U` *(Shift+u)* | **Update** all installed plugins |
| `<Prefix> Alt + u` | **Uninstall** unlisted plugins |
