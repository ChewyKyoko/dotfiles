import QtQuick
import qs.services
import qs.theme

Rectangle {
    id: root

    implicitWidth: timeLabel.contentWidth + 20
    implicitHeight: timeLabel.contentHeight + 15

    color: Theme.surface_container
    radius: height / 2

    Text {
        id: timeLabel

        anchors.centerIn: parent

        text: Time.time
        color: Theme.on_surface_variant

        font {
            family: "Google Sans Medium"
            pointSize: 14
        }
    }
}
