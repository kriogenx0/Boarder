import AppKit

struct PasteboardSnapshot {
    let content: ClipboardItem.Content
}

/// Polls NSPasteboard.general.changeCount on a timer, since macOS has no push
/// notification for clipboard changes. Detects both plain text and image copies.
@MainActor
final class PasteboardWatcher {
    private let pasteboard: NSPasteboard
    private let onChange: (PasteboardSnapshot) -> Void
    private var timer: Timer?
    private var lastChangeCount: Int

    init(pasteboard: NSPasteboard = .general, onChange: @escaping (PasteboardSnapshot) -> Void) {
        self.pasteboard = pasteboard
        self.onChange = onChange
        self.lastChangeCount = pasteboard.changeCount
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.poll()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        guard let snapshot = currentSnapshot() else { return }
        onChange(snapshot)
    }

    private func currentSnapshot() -> PasteboardSnapshot? {
        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            return PasteboardSnapshot(content: .text(string))
        }
        if let imageData = pngData() {
            return PasteboardSnapshot(content: .image(imageData))
        }
        return nil
    }

    private func pngData() -> Data? {
        guard let image = NSImage(pasteboard: pasteboard) else { return nil }
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else { return nil }
        return png
    }
}
