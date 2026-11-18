# Per-monitor Workspaces Toggle

Omarchy gives every monitor its own workspaces 1-10 since [omacom/omarchy#15655](https://github.com/omacom/omarchy/pull/15655). This plugin adds a toggle that switches back to workspaces numbered 1-10 across all monitors, and back again.

## Use

- Click the bar icon. A single monitor icon means global workspaces, a double one means per-monitor.
- Open the Omarchy menu at Trigger > Toggle and pick Global Workspaces or Per-monitor Workspaces.
- From a terminal or a keybinding, run `~/.config/omarchy/plugins/feature-ninja.per-monitor-workspaces/bin/per-monitor-workspaces [toggle|on|off|status]`.

## What off changes

- `Super + 1-0`, `Super + Shift + 1-0` and `Super + Shift + Alt + 1-0` act on global workspaces 1-10.
- `Super + Tab`, `Super + Shift + Tab`, `Super + Ctrl + Tab` and `Super + scroll` cycle through all workspaces.
- `Super + Shift + Alt + Arrows` moves the workspace to another monitor without renumbering it.
- Omarchy stops renumbering workspaces on reloads and hotplugs.
- Every monitor's bar lists workspaces 1-10.
- Workspaces left at 11 and up move into free numbers 1-10.

`Super + Shift + Ctrl + Arrows` (move window to monitor) stays in both modes.

## How it works

Off writes `~/.local/state/omarchy/toggles/hypr/per-monitor-workspaces-off.lua`, which loads `hypr/global-workspaces.lua` after Omarchy's bindings and yours. That file points `o.workspaces` at global dispatchers and rebinds the keys above. The bar reads each monitor's block of ten from `~/.local/state/omarchy/monitor-workspaces`, so off puts every monitor on block 0 there. The real assignments wait in `monitor-workspaces.per-monitor` and return when you switch back on, so each monitor gets its old block.

Omarchy's menu only reads its own defaults and `~/.config/omarchy/extensions/omarchy-menu.jsonc`, so the plugin's service writes the two Toggle rows into a marked block in that file each time the shell starts. The block follows the plugin if its folder moves. Once the plugin is gone, the rows hide themselves, and you can delete the block.

A switch that renumbers workspaces restarts the Omarchy shell, because Quickshell keeps listing the old numbers in the bar until it restarts.

## Caveats

- While off, the plugin's bindings replace any custom bindings you made on the same keys in `~/.config/hypr/bindings.lua`.
- Saved per-workspace layouts (scrolling, floating) are keyed by number, so a renumbered workspace loses its layout. Omarchy has the same gap.
