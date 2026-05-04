# tmux_config

Personal tmux setup with vi-style copy mode, fzf/sesh session switching, gruvbox theme, and persistent sessions across reboots via tmux-resurrect + tmux-continuum.

Lives at `~/.config/tmux/`.

## Requirements

| Tool | Why |
|---|---|
| `tmux` ≥ 3.2 | Popups, hooks, modern options |
| `git` | TPM clones plugins via git |
| `fzf` | Session picker + key-binding help |
| `sesh` | Multi-source session switcher (`prefix + T`, `prefix + o`) |
| `fd` | `ctrl-f` find-mode in the sesh picker |
| `xclip` | System clipboard yank from copy mode |
| `zoxide` (optional) | `ctrl-x` zoxide source in sesh picker |

## Install

```bash
git clone git@github.com:dhruvthanki/tmux_config.git ~/.config/tmux

# TPM (plugin manager) is required and not vendored — clone it once:
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Start tmux, then install plugins
tmux
#   inside tmux:  prefix + I    (capital i)
```

Reload after edits with `prefix + r`.

## Sesh setup

[`sesh`](https://github.com/joshmedeski/sesh) powers `prefix + T` (multi-source picker) and `prefix + o` (jump to last session). It works with **zero config** — out of the box it pulls tmux sessions, zoxide directories, and `fd` results.

**Install** (pick one):

```bash
# Go (what's installed on this machine — drops the binary in ~/.local/bin or ~/go/bin)
go install github.com/joshmedeski/sesh/v2@latest

# Homebrew (macOS / Linuxbrew)
brew install joshmedeski/sesh/sesh

# Or grab a prebuilt binary from the releases page:
#   https://github.com/joshmedeski/sesh/releases
```

Make sure the install directory is on `$PATH` (e.g. `~/.local/bin` or `~/go/bin`).

**Optional helpers** — sesh's source modes degrade gracefully if these are missing, but the picker is much nicer with them installed:

| Tool | Powers |
|---|---|
| `fzf` | The picker UI itself (also required by tmux's `prefix + O`) |
| `zoxide` | `Ctrl-x` recent-directories source in the picker |
| `fd` | `Ctrl-f` find-mode (`fd -H -d 2 -t d -E .Trash . ~`) |

**Config** (optional) — drop a `~/.config/sesh/sesh.toml` to predefine named sessions, startup commands, or per-project layouts. See the [sesh README](https://github.com/joshmedeski/sesh#configuration) for the schema. Without it, sesh runs on defaults.

## Prefix

The prefix key is **`` ` ``** (backtick), not `Ctrl-b`. Press backtick twice to type a literal backtick.

## Key bindings

> Notation: `prefix` = `` ` ``. `M-` = Alt. Bindings written without `prefix` use `bind -n` and need no leader.

### Sessions

| Keys | Action |
|---|---|
| `prefix O` | fzf popup session switcher (creates if name is new, `Ctrl-K` to kill) |
| `prefix T` | sesh popup with multi-source switching (see sesh modes below) |
| `prefix o` | jump to last session (via sesh) |
| `prefix S` | prompt for name and create new session |
| `prefix k` | list every key binding through fzf (searchable cheatsheet) |

**`prefix + T` sesh modes** (switch source while inside the picker):

| Key | Source |
|---|---|
| `Ctrl-a` | All (default) |
| `Ctrl-t` | Tmux sessions only |
| `Ctrl-g` | Sesh configs |
| `Ctrl-x` | zoxide directories |
| `Ctrl-f` | `fd`-discovered directories under `~` |
| `Ctrl-d` | Kill the highlighted tmux session |
| `Tab` / `Shift-Tab` | Move down / up |

### Windows

| Keys | Action |
|---|---|
| `prefix c` | New window **after** current, in current path |
| `prefix C` | New window **at end**, in current path |
| `Ctrl-H` / `Ctrl-L` | Previous / next window (no prefix) — see ⚠ below |
| `M-Shift-Left` / `M-Shift-Right` | Previous / next window |
| `M-i` / `M-o` | Swap current window left / right (no prefix) |

> ⚠ `Ctrl-H` / `Ctrl-L` collide with `vim-tmux-navigator` (which binds `Ctrl-h` / `Ctrl-l` for pane motion). Most terminals can't distinguish `Ctrl-h` from `Ctrl-Shift-h`, so the navigator wins. Use `M-Shift-Left/Right` for window navigation in practice.

### Panes — splitting & creating

| Keys | Action |
|---|---|
| `prefix "` or `prefix -` | Split horizontally (new pane below), inherit path |
| `prefix %` or `prefix \|` | Split vertically (new pane right), inherit path |

### Panes — moving

| Keys | Action |
|---|---|
| `Ctrl-h` / `Ctrl-j` / `Ctrl-k` / `Ctrl-l` | Move left / down / up / right (vim-tmux-navigator, seamless with vim) |
| `Ctrl-\` | Toggle to last pane (vim-tmux-navigator) |
| `M-Left` / `M-Right` | Smart pane move; falls through to prev/next window at screen edge |
| `M-Up` / `M-Down` | Pane up / down |

### Panes — resizing & layout

Resize bindings are **repeatable** — hold the prefix and tap the key multiple times.

| Keys | Action |
|---|---|
| `prefix H` / `J` / `K` / `L` | Resize 5 cells left / down / up / right |
| `prefix Left` / `Down` / `Up` / `Right` | Same, with arrow keys |
| `prefix m` | Maximize / unmaximize the current pane (zoom) |

### Floating pane (tmux-floax)

| Keys | Action |
|---|---|
| `M-f` | Toggle floating pane (no prefix) |
| `prefix p` | Toggle floating pane (default plugin binding) |
| `prefix P` | Floax options menu |

### Copy / vi mode

Copy mode uses **vi keys** (`set -g mode-keys vi`). Enter copy mode with `prefix [`. The pane is highlighted in gruvbox bg1 (`#3c3836`) while you're in copy mode.

| Keys | Action |
|---|---|
| `v` | Begin character selection |
| `Ctrl-v` | Toggle rectangular (block) selection |
| `y` / `Y` | Yank selection to system clipboard via `xclip` and exit copy mode |
| `q` | Exit copy mode |

Mouse drag does **not** exit copy mode (`MouseDragEnd1Pane` unbound).

### Sessions — save & restore (tmux-resurrect)

Continuum auto-saves every 15 minutes and auto-restores when the tmux server starts.

| Keys | Action |
|---|---|
| `prefix Ctrl-s` | Manual save |
| `prefix Ctrl-r` | Manual restore |

Pane scrollback is captured (`@resurrect-capture-pane-contents 'on'`).

### Misc

| Keys | Action |
|---|---|
| `prefix r` | Reload `tmux.conf` |
| `prefix \`` | Send a literal backtick |
| `prefix /` | Regex search (tmux-copycat) |
| `prefix Ctrl-f` | Find file (copycat) |
| `prefix Ctrl-u` | Find URL (copycat) |
| `prefix o` (in copy mode) | Open highlighted text (tmux-open) |
| `prefix Ctrl-o` (in copy mode) | Open in `$EDITOR` (tmux-open) |
| `prefix j` | Jump-mode quick cursor motion (tmux-jump) |

## Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm). The `plugins/` directory is gitignored — TPM re-clones each plugin on `prefix + I`.

| Plugin | Purpose |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [tmux-gruvbox](https://github.com/egel/tmux-gruvbox) | Theme (`dark` variant) |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless vim ↔ tmux pane motion |
| [tmux-floax](https://github.com/omerxx/tmux-floax) | Floating scratch pane |
| [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) | Regex search in copy mode |
| [tmux-open](https://github.com/tmux-plugins/tmux-open) | Open highlighted URLs / files |
| [tmux-jump](https://github.com/schasse/tmux-jump) | EasyMotion-style jump |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save / restore sessions |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto save + auto restore |

## Theme

Gruvbox dark with a custom status line:

| Section | Content |
|---|---|
| Status position | top |
| Left A | session name (`#S`) |
| Right X | current pane command |
| Right Y | `YYYY-MM-DD HH:MM` |
| Right Z | hostname |

## Custom scripts

Lives in `scripts/`:

- **`session-fzf.sh`** — backs `prefix + O`. Lists tmux sessions, lets you switch, kill (`Ctrl-K`), or create-by-typing-and-pressing-enter.
- **`session-preview.sh`** — preview pane for the picker; shows the windows/panes inside the highlighted session.

## Notable behavior

- **Mouse off** — set explicitly to `off`. Use keys for everything.
- **Don't detach on session destroy** — `detach-on-destroy off` keeps you inside tmux when the current session is killed.
- **Windows + panes start at 1**, not 0. Renumber on close.
- **No automatic window renaming** (`allow-rename off`) so titles you set stay set.
- **256-color + true color** via `tmux-256color` + `Tc` override.
- **Clipboard** synced through OSC 52 (`set-clipboard on`) and explicit `xclip` in copy mode.

## File layout

```
~/.config/tmux/
├── tmux.conf              # the config
├── README.md              # this file
├── .gitignore             # ignores plugins/ and resurrect/
├── scripts/
│   ├── session-fzf.sh
│   └── session-preview.sh
└── plugins/               # TPM-managed (gitignored)
    ├── tpm/
    └── ...
```
