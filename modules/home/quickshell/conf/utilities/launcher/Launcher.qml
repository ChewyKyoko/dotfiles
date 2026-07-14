import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell.Io
import "../../theme"

PanelWindow {
    id: launcherWindow

    implicitWidth: 800
    implicitHeight: 739
    color: "transparent"
    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "launcher_overlay"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: -1

    anchors {
        bottom: true
    }

    margins {
        bottom: 170
    }

    LauncherBackend {
        id: ctrl

        onOpenMenuRequested: {
            if (launcherWindow.visible) {
                closeMenu();
            } else {
                ctrl.searchText = ""; // Reset backend state
                launcherWindow.visible = true; // Triggers UI build
            }
        }

        onCloseMenuRequested: closeMenu()
    }

    // ScriptModel outside LazyLoader so binding engine tracks ctrl.filteredApps properly
    ScriptModel {
        id: appModel
        values: ctrl.filteredApps
    }

    function closeMenu() {
        launcherWindow.visible = false; // Destroys the UI and frees memory
    }

    LazyLoader {
        id: contentLoader

        activeAsync: launcherWindow.visible

        component: Component {
            Item {
                id: lazyContentRoot

                parent: launcherWindow.contentItem
                anchors.fill: parent

                anchors.margins: 80
                anchors.bottomMargin: 50

                // Click on transparent background closes launcher
                MouseArea {
                    anchors.fill: parent
                    onClicked: launcherWindow.closeMenu()
                }

                Component.onCompleted: {
                    searchField.forceActiveFocus();
                }

                Rectangle {
                    id: shadowCaster
                    anchors.fill: mainUi
                    anchors.margins: 2
                    radius: 26
                    color: "black"
                    visible: false
                }

                MultiEffect {
                    anchors.fill: shadowCaster
                    source: shadowCaster
                    shadowEnabled: true
                    shadowBlur: 1.5
                    shadowColor: "#60000000"
                    shadowVerticalOffset: 16
                }

                Rectangle {
                    id: mainUiMask
                    anchors.fill: mainUi
                    radius: 28
                    color: "black"
                    visible: false
                    layer.enabled: true
                    layer.smooth: true
                }

                Rectangle {
                    id: mainUi
                    anchors.fill: parent
                    color: Theme.surface_container
                    radius: 28
                    focus: true

                    layer.enabled: true
                    layer.smooth: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: mainUiMask
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }

                    Item {
                        id: edgeBanner
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 180

                        Loader {
                            anchors.fill: parent
                            active: Theme.wallpaper !== ""
                            sourceComponent: Image {
                                anchors.fill: parent
                                source: Theme.wallpaper
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.primary
                            opacity: 0.15
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 80
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "transparent"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#40000000"
                                }
                            }
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (searchField.activeFocus)
                            return;

                        if (event.key === Qt.Key_Escape) {
                            launcherWindow.closeMenu();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Slash || event.key === Qt.Key_I) {
                            searchField.forceActiveFocus();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_J || event.key === Qt.Key_Down) {
                            listView.incrementCurrentIndex();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_K || event.key === Qt.Key_Up) {
                            listView.decrementCurrentIndex();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            if (listView.currentItem)
                                listView.currentItem.launch();
                            event.accepted = true;
                        }
                    }

                    Rectangle {
                        id: searchArea
                        height: 64
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 32
                        anchors.rightMargin: 32

                        anchors.verticalCenter: edgeBanner.bottom

                        radius: height / 2
                        color: Theme.surface_container_highest

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowBlur: 1.0
                            shadowColor: "#40000000"
                            shadowVerticalOffset: 4
                        }

                        TextField {
                            id: searchField
                            anchors.fill: parent
                            anchors.margins: 12
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            leftPadding: 48
                            rightPadding: searchField.text !== "" ? 48 : 16
                            font {
                                family: "Google Sans"
                                pixelSize: 17
                            }
                            color: Theme.on_surface
                            selectionColor: Theme.primary_container
                            selectedTextColor: Theme.on_primary_container
                            placeholderText: "Search apps..."
                            placeholderTextColor: Theme.on_surface_variant

                            property string debouncedText: ""

                            Timer {
                                id: searchDebounce
                                interval: 120
                                repeat: false
                                onTriggered: {
                                    ctrl.searchText = searchField.debouncedText;
                                    if (listView) listView.currentIndex = 0;
                                }
                            }

                            background: Rectangle {
                                id: searchBg
                                color: searchField.activeFocus ? Theme.surface_container_highest : Theme.surface_container_high
                                radius: 28
                                border.width: searchField.activeFocus ? 2 : 1
                                border.color: searchField.activeFocus ? Theme.primary : Theme.outline_variant
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "search"
                                    font.family: "Material Symbols Rounded"
                                    font.pixelSize: 28
                                }
                            }

                            onTextChanged: {
                                debouncedText = text;
                                searchDebounce.restart();
                            }

                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Escape) {
                                    mainUi.forceActiveFocus();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                    if (listView.currentItem)
                                        listView.currentItem.launch();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_J && (event.modifiers & Qt.ControlModifier))) {
                                    listView.incrementCurrentIndex();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier))) {
                                    listView.decrementCurrentIndex();
                                    event.accepted = true;
                                }
                            }
                        }
                    }

                    Item {
                        id: listContainer
                        anchors.top: searchArea.bottom
                        anchors.topMargin: 16
                        anchors.bottom: footer.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        clip: true

                        ListView {
                            id: listView
                            anchors.fill: parent
                            topMargin: 12
                            bottomMargin: 24
                            spacing: 4

                            highlightMoveDuration: 120
                            highlightFollowsCurrentItem: true
                            delegate: LauncherDelegate {}

                            model: appModel
                        }

                        Rectangle {
                            anchors {
                                bottom: parent.bottom
                                left: parent.left
                                right: parent.right
                            }
                            height: 48
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "transparent"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: Theme.surface_container
                                }
                            }
                        }
                    }

                    Text {
                        id: emptyMessage
                        anchors.centerIn: listContainer
                        text: "No matching applications"
                        visible: listView.count === 0
                        color: Theme.on_surface_variant
                        font {
                            family: "Google Sans Medium"
                            pixelSize: 18
                        }
                    }

                    Item {
                        id: footer
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }
                        height: 48

                        Text {
                            anchors.centerIn: parent
                            text: "[/] Search  •  [Enter] Launch  •  [J/K] Navigate  •  [Esc] Close"
                            color: Theme.on_surface_variant
                            opacity: 0.7
                            font {
                                family: "Google Sans"
                                pixelSize: 12
                                weight: Font.Medium
                                letterSpacing: 0.5
                            }
                        }
                    }
                }
            }
        }
    }
}
