# Per-monitor Workspaces Toggle

Omarchy gives every monitor its own workspaces 1-10 since [omacom/omarchy#15655](https://github.com/omacom/omarchy/pull/15655). This plugin adds a toggle that switches back to workspaces numbered 1-10 across all monitors, and back again.

## Requirements

- Omarchy with per-monitor workspaces ([omacom/omarchy#15655](https://github.com/omacom/omarchy/pull/15655)).
- `hyprctl`, `jq` and `awk`, which Omarchy installs.

## Install

```bash
omarchy plugin add https://github.com/feature-ninja/per-monitor-workspace-toggle --enable
```

This puts the toggle icon on the bar. Installing changes nothing else. Workspaces stay per-monitor until you switch.

To also get the toggle under Trigger > Toggle in the Omarchy menu, add its rows to `~/.config/omarchy/extensions/omarchy-menu.jsonc`:

```bash
~/.config/omarchy/plugins/feature-ninja.per-monitor-workspaces/bin/per-monitor-workspaces menu install
```

The rows go in a marked block, and the rest of the file is left as it is. Run it again after moving the plugin, so the rows point at the new path.

## Use

- Click the bar icon. A single monitor icon means global workspaces, a double one means per-monitor.
- Open the Omarchy menu at Trigger > Toggle and pick Global Workspaces or Per-monitor Workspaces.
- From a terminal or a keybinding, run `~/.config/omarchy/plugins/feature-ninja.per-monitor-workspaces/bin/per-monitor-workspaces [toggle|on|off|status]`.

## Remove

Switch back to per-monitor first, so Omarchy gets each monitor's saved block back, then take out the menu rows and the plugin:

```bash
bin=~/.config/omarchy/plugins/feature-ninja.per-monitor-workspaces/bin/per-monitor-workspaces
$bin on
$bin menu remove
omarchy plugin remove feature-ninja.per-monitor-workspaces
```

## What off changes

- `Super + 1-0`, `Super + Shift + 1-0` and `Super + Shift + Alt + 1-0` act on global workspaces 1-10.
- `Super + Tab`, `Super + Shift + Tab`, `Super + Ctrl + Tab` and `Super + scroll` cycle through all workspaces.
- `Super + Shift + Alt + Arrows` moves the workspace to another monitor without renumbering it.
- Omarchy stops renumbering workspaces on reloads and hotplugs.
- Every monitor's bar lists workspaces 1-10.
- Workspaces left at 11 and up move into free numbers 1-10.
- `Super + Shift + Ctrl + Arrows` (move window to monitor), which per-monitor mode added, is unbound.

## How it works

Off writes `~/.local/state/omarchy/toggles/hypr/per-monitor-workspaces-off.lua`, which loads `hypr/global-workspaces.lua` after Omarchy's bindings and yours. That file points `o.workspaces` at global dispatchers and rebinds the keys above. The bar reads each monitor's block of ten from `~/.local/state/omarchy/monitor-workspaces`, so off puts every monitor on block 0 there. The real assignments wait in `monitor-workspaces.per-monitor` and return when you switch back on, so each monitor gets its old block.

Omarchy's menu only reads its own defaults and `~/.config/omarchy/extensions/omarchy-menu.jsonc`, so `menu install` writes the two Toggle rows into a marked block in that file, and `menu remove` deletes the block. If the plugin is removed first, the rows hide themselves.

A switch that renumbers workspaces restarts the Omarchy shell, because Quickshell keeps listing the old numbers in the bar until it restarts.

## Caveats

- While off, the plugin's bindings replace any custom bindings you made on the same keys in `~/.config/hypr/bindings.lua`, and your own `Super + Shift + Ctrl + Arrows` bindings are removed.
- A workspace created above 10 while off, such as by a window rule, shows in the bar after 1-10 until the next reload moves it into a free slot.
- The menu rows are English only, because the menu file has no translation support.
- Saved per-workspace layouts (scrolling, floating) are keyed by number, so a renumbered workspace loses its layout. Omarchy has the same gap.

## License

MIT. See [LICENSE](LICENSE).
