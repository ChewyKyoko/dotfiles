import QtQuick
import "../../theme"

Item {
    id: delegateRoot

    width: GridView.view ? GridView.view.cellWidth : 60
    height: GridView.view ? GridView.view.cellHeight : 60

    property string emojiName: modelData.display
    property string emojiChar: modelData.emoji

    property bool isSelected: GridView.isCurrentItem
    property bool isHovered: itemMouseArea.containsMouse

    Rectangle {
        anchors.centerIn: parent

        // Dynamic dimension scaling
        width: 52
        height: 52
        radius: 16

        color: delegateRoot.isSelected ? Theme.primary_container : (delegateRoot.isHovered ? Theme.surface_container_highest : "transparent")

        Text {
            anchors.centerIn: parent

            text: delegateRoot.emojiChar

            font {
                family: "Noto Color Emoji"
                pixelSize: 28
            }

            renderType: Text.NativeRendering
        }

        MouseArea {
            id: itemMouseArea

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: delegateRoot.GridView.view.currentIndex = index

            onClicked: function(mouse) {
                emojiWindow.processSelection(delegateRoot.emojiChar, mouse.modifiers & Qt.ShiftModifier);
            }
        }
    }
}
