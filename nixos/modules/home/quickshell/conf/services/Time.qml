pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string time: Qt.formatDateTime(clock.date, " h:mm ap  •  ddd,  MMM d  ")

    // Reactive clock source tracking seconds.
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
