import QtQuick
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

  Process {
    id: status
    command: [root.script, "status"]
    stdout: StdioCollector {
      onStreamFinished: root.perMonitor = this.text.trim() !== "off"
    }
  }

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

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
    tooltipText: root.perMonitor ? strings.t("tooltip.perMonitor") : strings.t("tooltip.global")
    // bar.run detaches, so the shell restart a renumbering toggle triggers cannot cut it short.
    onPressed: function() { if (root.bar) root.bar.run(Util.shellQuote(root.script) + " toggle") }
  }
}
