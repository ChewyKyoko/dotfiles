import QtQuick
import Quickshell
import Quickshell.Wayland
import "."

Variants {
	model: Quickshell.screens

	delegate: PanelWindow {
		required property var modelData
		screen: modelData

		WlrLayershell.layer: WlrLayer.Background
		WlrLayershell.namespace: "quickshell-wallpaper"

		anchors { top: true; bottom: true; left: true; right: true }
		color: "transparent"

		Item {
			id: root
			anchors.fill: parent

			property string source: Theme.wallpaper
			property Item current

			onSourceChanged: {
				if (!source) {
					current = null
					return
				}
				current = imgComp.createObject(root, {source: root.source})
			}

			Component {
				id: imgComp

				Image {
					id: img
					anchors.fill: parent
					fillMode: Image.PreserveAspectCrop
					asynchronous: true

					opacity: 0

					onStatusChanged: {
						if (status === Image.Ready)
							anim.start()
					}

					NumberAnimation on opacity {
						id: anim
						running: false
						from: 0
						to: 1
						duration: 400
						easing.type: Easing.Bezier
						easing.bezierCurve: [0.0, 0.0, 0.2, 1.0]
					}

					Timer {
						running: root.current !== img && root.current?.status === Image.Ready
						interval: anim.duration
						onTriggered: img.destroy()
					}
				}
			}
		}
	}
}
