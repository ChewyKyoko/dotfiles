import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: backend

    // UI Orchestration Signals
    signal openMenuRequested
    signal closeMenuRequested

    property string searchText: ""

    // CHANGE THIS TO YOUR ACTUAL TERMINAL
    property string myTerminal: "kitty"

    // Hidden apps filter
    property var hiddenKeywords: ["avahi", "uuctl", "bssh", "bvnc"]

    // Filtered apps array — recomputed when searchText changes
    property var filteredApps: buildFilteredList()

    function scoreMatch(text, query) {
        if (!text) return -1;
        var textLower = text.toString().toLowerCase();
        var queryLower = query.toLowerCase();

        if (textLower === queryLower) return 1000;
        if (textLower.startsWith(queryLower)) return 800;

        var words = textLower.split(/[\s\-_]+/);
        for (var i = 0; i < words.length; i++) {
            if (words[i].startsWith(queryLower)) return 600;
        }

        if (query.length >= 3 && textLower.indexOf(queryLower) !== -1) return 200;
        return -1;
    }

    function buildFilteredList() {
        var allApps = DesktopEntries.applications.values;
        var query = searchText.trim();
        var queryLower = query.toLowerCase();

        if (query === "") {
            return allApps.filter(function(app) {
                if (!app.name) return false;
                var n = app.name.toLowerCase();
                return !hiddenKeywords.some(function(keyword) { return n.includes(keyword); });
            }).sort(function(a, b) { return (a.name || "").localeCompare(b.name || ""); });
        }

        var isSearchingHidden = hiddenKeywords.some(function(keyword) { return queryLower.includes(keyword); });
        var scored = [];

        for (var i = 0; i < allApps.length; i++) {
            var entry = allApps[i];
            var nameLower = entry.name ? entry.name.toLowerCase() : "";
            var isHiddenApp = hiddenKeywords.some(function(keyword) { return nameLower.includes(keyword); });

            if (isHiddenApp && !isSearchingHidden) continue;

            var best = scoreMatch(entry.name, query);

            if (entry.genericName) {
                var s = scoreMatch(entry.genericName, query);
                if (s >= 200) best = Math.max(best, s - 50);
            }

            if (entry.comment) {
                var s = scoreMatch(entry.comment, query);
                if (s >= 200) best = Math.max(best, s - 100);
            }

            if (entry.keywords) {
                for (var j = 0; j < entry.keywords.length; j++) {
                    var s = scoreMatch(entry.keywords[j], query);
                    if (s >= 200) best = Math.max(best, s - 20);
                }
            }

            if (entry.execString && entry.execString.toLowerCase().includes(queryLower)) {
                best = Math.max(best, 180);
            }

            if (best >= 0) {
                scored.push({ entry: entry, score: best });
            }
        }

        scored.sort(function(a, b) {
            if (b.score !== a.score) return b.score - a.score;
            return (a.entry.name || "").localeCompare(b.entry.name || "");
        });

        return scored.map(function(s) { return s.entry; });
    }

    function launchApp(desktopEntry) {
        var finalCommand = [];

        // Wrap the launch in UWSM so systemd tracks the app properly
        finalCommand.push("uwsm");
        finalCommand.push("app");
        finalCommand.push("--");

        if (desktopEntry.runInTerminal) {
            finalCommand.push(myTerminal);
            finalCommand.push("--");
        }

        finalCommand = finalCommand.concat(desktopEntry.command);

        Quickshell.execDetached({
            command: finalCommand,
            workingDirectory: desktopEntry.workingDirectory
        });

        backend.closeMenuRequested();
    }

    IpcHandler {
        target: "appLauncher"
        function toggle() {
            backend.openMenuRequested();
        }
    }
}
