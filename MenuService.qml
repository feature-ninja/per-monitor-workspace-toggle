import QtQuick
import Quickshell

// Puts the toggle under Trigger > Toggle in the Omarchy menu whenever the
// plugin is enabled, whether or not its widget is on the bar.
Item {
  property var shell: null

  Component.onCompleted: {
    var script = String(Qt.resolvedUrl("bin/per-monitor-workspaces")).replace(/^file:\/\//, "")
    Quickshell.execDetached([script, "menu"])
  }
}
