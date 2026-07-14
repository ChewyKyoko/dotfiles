import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

Rectangle {
    id: root

    property string targetMonitor: ""

    readonly property int animDurationShort: 150
    readonly property int animDurationLong: 200
    readonly property int dotHeight: 20
    readonly property int spacingAmount: 10

    property var tags: []

    implicitWidth: mainLayout.width + 30
    implicitHeight: mainLayout.height + 18
    color: Theme.surface_container
    radius: height / 2

    function updateFromJson(jsonText) {
        try {
            var data = JSON.parse(jsonText);
            var allTags = data.all_tags;
            if (!allTags) return;

            for (var mi = 0; mi < allTags.length; mi++) {
                if (allTags[mi].monitor === root.targetMonitor) {
                    // Show only tags 1-6 (index >= 1 && <= 6)
                    var all = allTags[mi].tags || [];
                    root.tags = all.filter(function(t) { return t.index >= 1 && t.index <= 6; });
                    return;
                }
            }
        } catch (e) {
            console.error("Workspaces: failed to parse tags JSON", e);
        }
    }

    // Stream workspace tag updates from mmsg watch
    Process {
        id: watchProcess
        command: ["mmsg", "watch", "all-tags"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(data) {
                root.updateFromJson(data.trim());
            }
        }
        onRunningChanged: {
            // Restart the watcher if it exits
            if (!running) {
                running = true;
            }
        }
    }

    Row {
        id: mainLayout
        anchors.centerIn: parent
        spacing: root.spacingAmount

        Repeater {
            model: root.tags

            delegate: Rectangle {
                id: workspaceDot

                visible: modelData.index >= 1

                width: {
                    if (!visible) return 0;
                    if (modelData.is_active) return 40;
                    if (dotMouseArea.hovered) return 32;
                    return 24;
                }

                height: root.dotHeight
                radius: height / 2

                color: {
                    if (modelData.is_urgent) return Theme.critical;
                    if (modelData.is_active) return Theme.primary;
                    if (modelData.client_count > 0) return Theme.secondary;
                    return dotMouseArea.hovered ? Theme.on_surface_variant : Theme.outline;
                }

                Behavior on width {
                    NumberAnimation {
                        duration: root.animDurationLong
                        easing.type: Easing.OutBack
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: root.animDurationShort
                    }
                }

                TapHandler {
                    onTapped: {
                        Quickshell.execDetached({
                            command: ["mmsg", "dispatch", "view," + modelData.index + ",0"]
                        });
                    }
                }

                HoverHandler {
                    id: dotMouseArea
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
