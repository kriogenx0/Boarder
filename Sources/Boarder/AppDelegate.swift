import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store: ClipboardHistoryStore!
    private var watcher: PasteboardWatcher!
    private var statusItemController: StatusItemController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = ClipboardHistoryStore()
        self.store = store

        let watcher = PasteboardWatcher { [weak store] snapshot in
            store?.recordNewPasteboardContent(snapshot)
        }
        watcher.start()
        self.watcher = watcher

        statusItemController = StatusItemController(store: store)
    }

    func applicationWillTerminate(_ notification: Notification) {
        watcher.stop()
    }
}
