import Quickshell
import Quickshell.Wayland
import QtQuick
import "modules"
import qs.theme

Variants {
    id: root
    model: Quickshell.screens

    delegate: PanelWindow {
        id: mainBar

        required property var modelData
        screen: modelData

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell-topbar"

        anchors {
            top: true
            left: true
            right: true
        }

        color: "transparent"
        implicitHeight: Layout.topBarHeight

        Workspaces {
            id: workspaceModule
            targetMonitor: modelData.name

            anchors {
                left: parent.left
                leftMargin: 15
                verticalCenter: parent.verticalCenter
            }
        }

        Calendar {
            id: calendarModule
            anchors.centerIn: parent
        }

        SystemStats {
            id: statusModule

            anchors {
                right: parent.right
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
