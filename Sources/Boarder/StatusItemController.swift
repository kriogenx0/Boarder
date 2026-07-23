import AppKit
import SwiftUI

/// Owns the NSStatusItem (surfboard icon) and the NSPopover that hosts the SwiftUI history list.
/// Uses classic AppKit status item + popover rather than SwiftUI's MenuBarExtra so the popover
/// gets a real arrow, precise sizing, and reliable click-outside dismissal.
@MainActor
final class StatusItemController: NSObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover

    init(store: ClipboardHistoryStore) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 420)
        popover.contentViewController = NSHostingController(rootView: HistoryListView(store: store))
        self.popover = popover

        super.init()

        statusItem.button?.image = SurfboardIcon.renderTemplateImage()
        statusItem.button?.action = #selector(togglePopover)
        statusItem.button?.target = self
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.close()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
