import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "feature-ninja.per-monitor-workspaces"

  readonly property string script: String(Qt.resolvedUrl("bin/per-monitor-workspaces")).replace(/^file:\/\//, "")
  property bool perMonitor: true

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function readStatus() {
    if (!status.running) status.running = true
  }

  // Detached, because a toggle that renumbers workspaces restarts the shell.
  function toggle() {
    Quickshell.execDetached([root.script, "toggle"])
  }

  Process {
    id: status
    command: [root.script, "status"]
    stdout: StdioCollector {
      onStreamFinished: root.perMonitor = this.text.trim() !== "off"
    }
  }

  Component.onCompleted: root.readStatus()

  // Every toggle reloads Hyprland, from this widget or the CLI.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event && String(event.name) === "configreloaded") root.readStatus()
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.perMonitor ? "󰍺" : "󰍹"
    active: !root.perMonitor
    tooltipText: root.perMonitor ? "Workspaces per monitor (click for global)" : "Workspaces across all monitors (click for per monitor)"
    onPressed: function() { root.toggle() }
  }
}
