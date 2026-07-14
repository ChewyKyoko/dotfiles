//@ pragma IconTheme Papirus

import Quickshell
import Quickshell.Io
import QtQuick
import "bar"
import "theme"
import qs.utilities.clipboard
import qs.utilities.emoji
import qs.utilities.launcher
import qs.utilities.wallpaper
import qs.popups
import qs.services

ShellRoot {
	id: root

	Wallpaper {}

	BezelsMask {
        id: desktopBezels
    }

    TopBar {
        id: topBar
    }

    NotifPopup {
        id: notificationOverlay
    }

    Clipboard {
        id: clipboardWindow
    }

    EmojiPicker {
        id: emojiPickerWindow
    }

    Launcher {
        id: launcherWindow
    }

    WallpaperSelector {
        id: wallpaperSelectorWindow
    }

    VolumePopup {
        id: volumePopupWindow
    }

    BrightnessPopup {
        id: brightnessPopupWindow
    }

    // Wallpaper state watcher — reacts instantly on file change, zero polling
    property string _cachePath: Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache"

    FileView {
        id: wallpaperWatcher
        path: root._cachePath + "/quickshell/wallpaper-state.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            property string wallpaper_path: ""
            onWallpaper_pathChanged: {
                if (wallpaper_path)
                    Theme.wallpaper = "file://" + wallpaper_path;
            }
        }
    }
}
