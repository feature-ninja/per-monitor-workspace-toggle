-- Workspaces numbered across all monitors, as before Omarchy gave each monitor
-- its own 1-10 (omacom/omarchy#15655). Loaded from Omarchy's Hyprland toggles
-- directory, after Omarchy's bindings and the user's.

local workspaces = o.workspaces
if not workspaces then
  return
end

local paths = require("default.hypr.paths")

local BLOCKS_FILE = paths.state_home .. "/omarchy/monitor-workspaces"
local SAVED_BLOCKS_FILE = BLOCKS_FILE .. ".per-monitor"

-- Omarchy renumbers workspaces into per-monitor blocks on every reload and
-- hotplug through these. The bar and close-all call the same functions.
workspaces.reconcile = function() end

workspaces.workspace_id = function(_, slot)
  return slot
end

workspaces.focus = function(slot)
  return hl.dsp.focus({ workspace = tostring(slot) })
end

workspaces.move_window = function(slot, follow)
  if follow == false then
    return hl.dsp.window.move({ workspace = tostring(slot), follow = false })
  end

  return hl.dsp.window.move({ workspace = tostring(slot) })
end

workspaces.move_to_monitor = function(direction)
  return hl.dsp.workspace.move({ monitor = direction })
end

-- The bar shows the block of ten that this file gives a monitor's connector.
-- Putting every monitor on block 0 makes each bar list workspaces 1-10. The
-- real assignments wait in a copy until the toggle turns per-monitor back on.
local function flatten_blocks()
  local saved = io.open(SAVED_BLOCKS_FILE, "r")
  if saved then
    saved:close()
  else
    os.rename(BLOCKS_FILE, SAVED_BLOCKS_FILE)
  end

  local lines = {}
  for _, monitor in ipairs(hl.get_monitors()) do
    lines[#lines + 1] = "0\t" .. monitor.name .. "\t" .. monitor.name .. "\n"
  end

  local file = io.open(BLOCKS_FILE, "w")
  if file then
    file:write(table.concat(lines))
    file:close()
  end
end

-- Per-monitor mode leaves workspaces at 11 and up, which Super + 1-0 can no
-- longer reach. Bring each into 1-10, on its own slot when that is free.
local function compact()
  local strays = {}
  for _, workspace in ipairs(hl.get_workspaces()) do
    if not workspace.special and workspace.id > 10 then
      strays[#strays + 1] = workspace.id
    end
  end
  table.sort(strays)

  for _, id in ipairs(strays) do
    local candidates = { (id - 1) % 10 + 1 }
    for slot = 1, 10 do
      candidates[#candidates + 1] = slot
    end

    for _, slot in ipairs(candidates) do
      if not hl.get_workspace(slot) then
        hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(id), id = slot }))
        break
      end
    end
  end
end

local function settle()
  compact()
  flatten_blocks()
end

flatten_blocks()
hl.on("hyprland.start", settle)
hl.on("config.reloaded", settle)
hl.on("monitor.added", flatten_blocks)
hl.on("monitor.removed", flatten_blocks)

if _G.omarchy_default_bindings == false then
  return
end

local bindings = {
  { "SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }) },
  { "SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }) },
  { "SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }) },
  { "SUPER + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }) },
  { "SUPER + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }) },
  { "SUPER + SHIFT + ALT + LEFT", "Move workspace to left monitor", workspaces.move_to_monitor("l") },
  { "SUPER + SHIFT + ALT + RIGHT", "Move workspace to right monitor", workspaces.move_to_monitor("r") },
  { "SUPER + SHIFT + ALT + UP", "Move workspace to up monitor", workspaces.move_to_monitor("u") },
  { "SUPER + SHIFT + ALT + DOWN", "Move workspace to down monitor", workspaces.move_to_monitor("d") },
}

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  bindings[#bindings + 1] = { "SUPER + " .. key, "Switch to workspace " .. workspace, workspaces.focus(workspace) }
  bindings[#bindings + 1] = { "SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, workspaces.move_window(workspace) }
  bindings[#bindings + 1] = {
    "SUPER + SHIFT + ALT + " .. key,
    "Move window silently to workspace " .. workspace,
    workspaces.move_window(workspace, false),
  }
end

for _, binding in ipairs(bindings) do
  o.rebind(binding[1], binding[2], binding[3])
end
