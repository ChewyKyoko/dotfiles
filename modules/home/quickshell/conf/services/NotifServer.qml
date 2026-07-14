pragma Singleton

import QtQuick
import Quickshell.Services.Notifications

NotificationServer {
    id: notificationServer

    bodySupported: true
    actionsSupported: true
    imageSupported: true
    persistenceSupported: true

    onNotification: function(notification) {
        notification.tracked = true;
    }
}
