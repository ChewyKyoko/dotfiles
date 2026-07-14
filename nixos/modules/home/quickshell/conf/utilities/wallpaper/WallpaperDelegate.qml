import QtQuick
import Quickshell.Widgets
import "../../theme"

Item {
    id: delegateRoot

    required property url fileUrl
    required property int fileSize
    required property WallpaperBackend backend

    height: ListView.view ? ListView.view.height : 0
    width: backend ? height * backend.thumbAspectRatio : 0

    property bool isSelected: ListView.isCurrentItem
    property bool isActive: isSelected || wallMouseArea.containsMouse

    property string fileName: {
        if (!backend || !fileUrl) return ""
        let decoded = backend.safeDecodeURI(fileUrl.toString())
        return decoded.substring(decoded.lastIndexOf("/") + 1)
    }

    property string thumbUrl: {
        if (!backend || fileName === "") return ""
        let dot = fileName.lastIndexOf(".")
        let base = dot > 0 ? fileName.substring(0, dot) : fileName
        return "file://" + backend.thumbDir + "/" + encodeURIComponent(base) + ".jpg"
    }

    property string cacheBustString: ""
    property int retryCount: 0
    property bool hasFailed: false

    signal wallpaperSelected

    onFileUrlChanged: {
        retryTimer.stop()
        cacheBustString = ""
        retryCount = 0
        hasFailed = false
    }

    function triggerSetWallpaper() {
        if (backend) {
            backend.setWallpaper(delegateRoot.fileUrl)
            delegateRoot.wallpaperSelected()
        }
    }

    Item {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        scale: delegateRoot.isActive ? 1.04 : 1.0
        z: delegateRoot.isActive ? 10 : 1

        Behavior on scale {
            // OutCubic avoids overshoot — OutBack would resize ClippingRectangle FBO at each overshoot step
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        // Static background (no clipping) — shown behind ClippingRectangle while image loads
        Rectangle {
            anchors.fill: parent
            anchors.margins: delegateRoot.isActive ? 0 : 8
            radius: 20
            color: wallImg.status === Image.Ready ? "transparent" : Theme.surface_variant

            Behavior on anchors.margins {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }

        // Loading text (outside ClippingRectangle — doesn't need rounded corners, avoids FBO re-render)
        Column {
            anchors.centerIn: parent
            spacing: 6
            visible: wallImg.status !== Image.Ready

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: delegateRoot.hasFailed ? "Failed to generate thumbnail :(" : "Generating Thumbnail"
                color: delegateRoot.hasFailed ? Theme.critical : Theme.on_surface_variant
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                visible: !delegateRoot.hasFailed
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Please wait..."
                color: Theme.on_surface_variant
                opacity: 0.7
                font.pixelSize: 12
            }
        }

        // ClippingRectangle — only clips the Image + gradient (smallest possible FBO content)
        ClippingRectangle {
            id: container
            anchors.fill: parent
            anchors.margins: delegateRoot.isActive ? 0 : 8
            radius: 20
            color: "transparent"

            Behavior on anchors.margins {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            Image {
                id: wallImg
                anchors.fill: parent
                source: delegateRoot.thumbUrl + delegateRoot.cacheBustString
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                sourceSize.width: 256
                sourceSize.height: 256

                onStatusChanged: {
                    if (status === Image.Ready) {
                        hasFailed = false
                        retryTimer.stop()
                        return
                    }
                    if (status === Image.Loading) {
                        hasFailed = false
                        return
                    }
                    if (status === Image.Error && source.toString().includes(delegateRoot.fileName)) {
                        if (delegateRoot.retryCount < 15) {
                            delegateRoot.retryCount++
                            retryTimer.start()
                        } else {
                            delegateRoot.hasFailed = true
                        }
                    }
                }
            }

            // Gradient info overlay — needs clipping at bottom corners
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 60
                visible: wallImg.status === Image.Ready

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#CC000000" }
                }

                Column {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 12
                    spacing: 2

                    Text {
                        text: delegateRoot.fileName
                        color: "white"
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: {
                            let bytes = delegateRoot.fileSize
                            if (!bytes) return ""
                            let kb = bytes / 1024
                            if (kb < 1024) return Math.round(kb) + " KB"
                            return (kb / 1024).toFixed(1) + " MB"
                        }
                        color: "#DDDDDD"
                        font.pixelSize: 11
                    }
                }
            }
        }

        // Selection/hover border
        Rectangle {
            anchors.fill: container
            radius: 20
            color: "transparent"
            border.color: Theme.primary
            border.width: delegateRoot.isActive ? 4 : 0
        }

        Timer {
            id: retryTimer
            interval: Math.min(1000 + (delegateRoot.retryCount * 250), 4000)
            repeat: false
            onTriggered: delegateRoot.cacheBustString = "?t=" + Date.now()
        }

        MouseArea {
            id: wallMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: delegateRoot.triggerSetWallpaper()
        }
    }
}
