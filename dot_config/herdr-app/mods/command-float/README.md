# Command Float

Configurable programs in floating Herdr terminals, derived from Nico Mayer's MIT-licensed `lazygit-herdr`.

## Configure

Edit `config.jsonc`. JSONC comments and trailing commas are supported; saving reloads the mod and its shortcuts.

```jsonc
{
  "paletteKey": "cmd-alt-p",
  "commands": [
    {
      "id": "lazygit",
      "label": "Lazygit",
      "command": "lazygit",
      "args": [],
      "cwd": "repo",
      "key": "ctrl-shift-g",
      "width": 0.9,
      "height": 0.9,
      "machines": { "work": "/opt/homebrew/bin/lazygit" }
    }
  ]
}
```

- `id`: stable lowercase identifier used in shortcuts and terminal labels.
- `command`: executable found on the target machine's PATH; no shell parsing.
- `args`: optional string array passed directly to the executable.
- `cwd`: `"focused"` for the focused terminal's exact folder, or `"repo"` for its Git root.
- `key`: optional toggle shortcut. Omit it to offer the command only in the picker.
- `width` / `height`: dialog size as a window fraction from 0.2 to 1.
- `machines`: optional executable overrides keyed by `hc machine` name; use `""` for this computer.
- `paletteKey`: picker shortcut, or `false` to remove its managed binding.

Shortcuts are merged into `keys.json` in both `global` and `terminal`. Existing unrelated bindings are never replaced; conflicts produce a notification and are skipped. Removing a command or changing its key removes the old managed binding on reload.

## Behavior

- A shortcut toggles its command. The picker opens with Cmd+Alt+P and supports arrows, Enter, Escape and clicks.
- The process stays running when hidden. One instance is reused per command, space and focused folder/repository.
- Opening another command hides the current dialog but leaves its process running.
- Clicking outside hides the dialog and restores the previous pane. Program exit closes it.
- Instances are cleaned after 30 minutes hidden or after their space closes, on the next command use.
- Local and remote spaces work through Herdr: lookup uses `exec(..., {on})`, and programs start with `hc run --on <machine>`.
- Commands and arguments never enter shell source text. PATH lookup uses `sh -c 'command -v "$1"'` on Unix and `where.exe` on local Windows.

## Verify

```sh
herdr-app check ~/.config/herdr-app/mods/command-float
node --test ~/.config/herdr-app/mods/command-float/model.test.mjs
```
