# 🎛️ Abel's Dotfiles (chezmoi) 📦

```text
         88                          ad88  88  88
         88                ,d       d8"    ""  88
         88                88       88         88
 ,adPPYb,88   ,adPPYba,  MM88MMM  MM88MMM  88  88   ,adPPYba,  ,adPPYba,
a8"    `Y88  a8"     "8a   88       88     88  88  a8P_____88  I8[    ""
8b       88  8b       d8   88       88     88  88  8PP"""""""   `"Y8ba,
"8a,   ,d88  "8a,   ,a8"   88,      88     88  88  "8b,   ,aa  aa    ]8I
 `"8bbdP"Y8   `"YbbdP"'    "Y888    88     88  88   `"Ybbd8"'  `"YbbdP"'
```

These configs mirror my macOS workflow: Zsh + Neovim + tmux + Ghostty + Aerospace + Homebrew, managed by `chezmoi`. A fresh machine is mostly a single `chezmoi init` + `chezmoi apply` away.

## 1. New machine setup (macOS)

1. **Install Homebrew**

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   Follow the post-install notes to add Homebrew to your `PATH`.

2. **Install chezmoi**

   ```sh
   brew install chezmoi
   ```

3. **Initialize and apply this repo**

   ```sh
   chezmoi init --apply https://github.com/abelfubu/dotfiles-omarchy
   ```

   - This prompts for `email` and `font` on the first run (set in `.chezmoi.yml.tmpl`).
   - It copies the `Brewfile` to `~` and runs `brew bundle` automatically.
   - It applies the macOS defaults script and browser extension policies.

4. **Restart** — log out and back in so input sources, menu bar auto-hide, and browser extension policies take effect.

5. **Open browsers** and let the managed extensions install.

### One-liner for new machines

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
  brew install chezmoi && \
  chezmoi init --apply https://github.com/abelfubu/dotfiles-omarchy
```

## 2. Linux setup

On Linux, skip the macOS defaults/browsers step. Install Homebrew and chezmoi, then run `chezmoi init --apply` with the same repo. Apply Hyprland/Waybar configs afterward only if you are on a Wayland host.

## 3. What's in here

| File/Area | Purpose |
| --- | --- |
| `Brewfile` | All Homebrew formulas, casks, fonts, npm packages, and third-party taps. Updated with `brew bundle dump` and applied automatically via `chezmoi apply`. |
| `run_onchange_after_brew-bundle.sh` | Re-runs `brew bundle` whenever the `Brewfile` changes. |
| `run_onchange_after_macos-defaults.sh` | macOS system defaults (Dock, Finder, keyboard, trackpad, menu bar, input sources, hot corners, screenshots, browser extension policies). |
| `dot_zshrc` | Zsh setup with `zoxide`, `mise`, `starship`, `fzf`, `zplug`, `eza`, and git aliases. |
| `dot_config/starship.toml` | Two-line prompt with git state and glyphs. |
| `dot_config/git/config.tmpl` | Git aliases, rebase-on-pull, histogram diffs, rerere, and `gh` credentials. |
| `dot_config/nvim/...` | Neovim Lua config. |
| `dot_config/tmux/tmux.conf` | `M-t` prefix, mouse, true-color, clean status. |
| `dot_config/aerospace/…` | macOS tiling window manager config. |
| `dot_config/ghostty/config.tmpl` | Ghostty terminal theming and fonts. |
| `dot_config/raycast` | Raycast config. |
| `dot_config/zed` | Zed editor config. |
| `dot_config/wezterm` | Wezterm config. |
| `dot_config/vicinae` | Vicinae file manager theme and keybindings. |
| `dot_config/hypr` / `dot_config/waybar` | Linux Wayland compositor configs. |
| `dot_local` | Machine-specific, non-public assets (themes, local overrides). |

## 4. Day-to-day tweaks

- Shell stays snappy: shared history, deferred Zplug plugins, and aliases that point `ls`/`vim` to their modern counterparts.
- Starship only shows git extras when needed and uses symbols for success/failure states.
- Neovim modules are organized under `lua/` so lazy-loaders can pick them up.
- Browser extensions are force-installed via managed policy, so they show as "installed by your administrator."

## 5. Maintenance

### Update apps after installing something new

```sh
brew bundle dump --force --file=$(chezmoi source-path)/Brewfile
chezmoi apply
```

This keeps the `Brewfile` in sync with your machine. The `run_onchange_after_brew-bundle.sh` hook will re-run `brew bundle` if the `Brewfile` changed.

### Remove unused apps/taps

After editing the `Brewfile` to remove things you no longer need:

```sh
brew bundle cleanup
```

Then commit the result.

### Change macOS defaults

Edit `run_onchange_after_macos-defaults.sh` and run:

```sh
chezmoi apply
```

Some changes need a logout/restart to fully take effect.

### Update template data

```sh
chezmoi data set email you@example.com
chezmoi data set font "SF Mono"
```

Then `chezmoi apply` to re-render templates.

---

Pull requests and suggestions welcome—thanks for stepping through my rig! ✨
