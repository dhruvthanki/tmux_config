# tmux_config

Personal tmux setup with vi-style copy mode, fzf/sesh session switching, gruvbox theme, and persistent sessions across reboots via tmux-resurrect + tmux-continuum. Also carries `tmux-sessionizer` and a cross-host session switcher, so the same clone works identically on every machine — see [Remote hosts](#remote-hosts) below.

Lives at `~/.config/tmux/`.

## Requirements

| Tool | Why |
|---|---|
| `tmux` ≥ 3.2 | Popups, hooks, modern options |
| `git` | TPM clones plugins via git; `remote-bootstrap.sh` clones/pulls this repo onto new hosts |
| `fzf` | Session pickers, key-binding help, `tmux-sessionizer` |
| `ssh` | `prefix + Space` cross-host switcher; needs key-based access to any host in `config/hosts.conf` already set up |
| `sesh` | Multi-source session switcher (`prefix + T`, `prefix + o`) |
| `fd` | `ctrl-f` find-mode in the sesh picker |
| — | Clipboard yank needs no host tool — tmux's own OSC 52 forwarding (`set-clipboard on`) reaches the real terminal even through nested SSH/tmux, including headless remotes with no `xclip`/`DISPLAY` |
| `zoxide` (optional) | `ctrl-x` zoxide source in sesh picker |

## Install

```bash
git clone git@github-personal:dhruvthanki/tmux_config.git ~/.config/tmux

# TPM (plugin manager) is required and not vendored — clone it once:
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

./install.sh   # symlinks tmux-sessionizer + its config into place

# Start tmux, then install plugins
tmux
#   inside tmux:  prefix + I    (capital i)
```

Reload after edits with `prefix + r`. On a host already added to `config/hosts.conf`, the very first `prefix + Space` attach to that host runs all of the above (clone/pull, TPM, `install.sh`) automatically via `remote-bootstrap.sh` — the manual steps above are only needed on the first machine, or on a brand-new host before it has SSH access to the git remote.

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
| `prefix Space` | cross-host session switcher — local + every host in `config/hosts.conf` (`Ctrl-K` to kill) |
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
| `y` / `Y` | Yank selection to system clipboard via OSC 52 and exit copy mode — works from a remote/nested session too, straight to your actual terminal's clipboard |
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

## Remote hosts

`config/hosts.conf` lists one SSH alias per line (blank/`#` lines ignored); `prefix + Space` merges `tmux list-sessions` from all of them with local sessions into one fzf popup. Deliberately minimal:

- **No control-mode bridge.** A remote pick opens a plain `ssh -t host tmux new -A -s session` in a new local window. Every keybinding, plugin, and bit of scrollback in that session is real, because it's a real independent tmux server — nothing is proxied or translated. The cost is a nested status bar/prefix in that one window, same as SSH+tmux has always had.
- **Auto-provisions new hosts.** First attach to a host not yet synced runs `remote-bootstrap.sh`: clone-or-pull this repo there, install TPM + plugins, run `install.sh`. After that, every host runs the *actual* config, not a hand-maintained copy — add a 3rd/4th machine by adding one line to `hosts.conf`, nothing else. This only works once a host already has SSH access to the git remote (the personal deploy key placed there) — that one bit of trust can't be bootstrapped remotely.
- **Doesn't create remote sessions.** Only lists what's already running. To spin up a new session on a host, use `tmux-sessionizer` from a shell on that host (see below).
- **No live activity dot for remote sessions yet.** The dot next to local sessions (see below) only reads this machine's status files today; wiring the same read over SSH per host is a small, deliberately deferred follow-up.
- **Safe to list a host that's also the current machine.** Since `hosts.conf` is synced verbatim to every host, running the picker *on* rlpc still has `rlpc` in its own copy of the file — `remote-picker.sh` compares each configured host's `hostname` against the local one and skips it, so it never tries to SSH into itself.

## tmux-sessionizer

[ThePrimeagen's script](https://github.com/ThePrimeagen/.dotfiles), extended, in `scripts/tmux-sessionizer` + `config/tmux-sessionizer.conf` (symlinked to `~/.local/bin` and `~/.config/tmux-sessionizer/` by `install.sh`). Fuzzy-picks a project directory under `TS_SEARCH_PATHS` *or* an already-running local tmux session, and attaches — creating the session from the directory name if it doesn't exist yet. Not bound to a tmux key here; invoke it directly from a shell (or bind it in your terminal emulator).

Extensions beyond the stock script: `TS_SESSION_COMMANDS` reserves windows at index 69+ for fixed companion commands per project (`-s 0` → the `claude .` window here, with pane-cache so `--vsplit`/`--hsplit` reuse it instead of duplicating), and `.tmux-sessionizer` hydration files let a project auto-run setup commands into a freshly created session.

## Agent activity dots

`scripts/agent-status-hook.sh <working|waiting|idle>` writes one line to a file per pane (`$TMUX_PANE`), read by `remote-picker.sh` to show a colored dot (green/yellow/grey) next to each local session. Wire it into lifecycle hooks so it actually gets called — e.g. Claude Code's `~/.claude/settings.json` hooks (`PreToolUse` → `working`, a permission/notification hook → `waiting`, `Stop` → `idle`); Codex has its own hook config with equivalent events. Without any hooks wired up, sessions just show the plain grey "idle" dot.

## Custom scripts

Lives in `scripts/`:

- **`session-fzf.sh`** — backs `prefix + O`. Lists tmux sessions, lets you switch, kill (`Ctrl-K`), or create-by-typing-and-pressing-enter.
- **`session-preview.sh`** — preview pane for the picker; shows the windows/panes inside the highlighted session. Reused as-is for remote previews (piped over SSH, since it only ever calls `tmux`).
- **`remote-picker.sh`** — backs `prefix + Space`; see [Remote hosts](#remote-hosts).
- **`remote-preview.sh`** — preview pane for `remote-picker.sh`; local or piped-over-SSH `session-preview.sh`.
- **`remote-bootstrap.sh`** — syncs a host's dotfiles/plugins/symlinks; called automatically, or run directly with `--force` to resync.
- **`agent-status-hook.sh`** — see [Agent activity dots](#agent-activity-dots).
- **`tmux-sessionizer`** — see [tmux-sessionizer](#tmux-sessionizer).

## Notable behavior

- **Mouse off** — set explicitly to `off`. Use keys for everything.
- **Don't detach on session destroy** — `detach-on-destroy off` keeps you inside tmux when the current session is killed.
- **Windows + panes start at 1**, not 0. Renumber on close.
- **No automatic window renaming** (`allow-rename off`) so titles you set stay set.
- **256-color + true color** via `tmux-256color` + `Tc` override.
- **Clipboard** synced purely through OSC 52 (`set-clipboard on` + an explicit `Ms` terminfo override) — no `pbcopy`/`xclip` dependency, and no per-host clipboard tool needed at all. This matters specifically for headless remotes: no `DISPLAY` means `xclip` can never work there, and even where it does, an OS clipboard command only ever reaches *that host's* clipboard, not the terminal you're actually looking at.

## File layout

```
~/.config/tmux/
├── tmux.conf                    # the config
├── install.sh                   # symlinks scripts/config into ~/.local/bin etc.
├── README.md                    # this file
├── .gitignore                   # ignores plugins/ and resurrect/
├── config/
│   ├── hosts.conf                 # remote-picker.sh's host list
│   └── tmux-sessionizer.conf       # tmux-sessionizer's search paths
├── scripts/
│   ├── session-fzf.sh
│   ├── session-preview.sh
│   ├── remote-picker.sh
│   ├── remote-preview.sh
│   ├── remote-bootstrap.sh
│   ├── agent-status-hook.sh
│   └── tmux-sessionizer
└── plugins/                     # TPM-managed (gitignored)
    ├── tpm/
    └── ...
```
