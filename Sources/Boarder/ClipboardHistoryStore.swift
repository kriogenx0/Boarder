import AppKit

@MainActor
final class ClipboardHistoryStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []
    @Published private(set) var selectedItemID: UUID?

    private let maxItems = 50
    private let fileURL: URL
    private let pasteboard: NSPasteboard

    /// storageDirectory and pasteboard are overridable so tests can use a scratch directory and a
    /// private pasteboard instead of touching the user's real app data / system clipboard.
    init(storageDirectory: URL? = nil, pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
        let supportDir = storageDirectory ?? FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Boarder", isDirectory: true)
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        fileURL = supportDir.appendingPathComponent("history.json")
        load()
    }

    /// Single entry point for anything observed on the system pasteboard. If the content exactly
    /// matches an existing entry, that entry is just moved to the front instead of duplicated -
    /// this is what keeps our own selectAndCopyToClipboard writes from creating a duplicate entry.
    func recordNewPasteboardContent(_ snapshot: PasteboardSnapshot) {
        if let existingIndex = items.firstIndex(where: { $0.matches(snapshot.content) }) {
            let existing = items.remove(at: existingIndex)
            items.insert(existing, at: 0)
            selectedItemID = existing.id
        } else {
            let item = ClipboardItem(content: snapshot.content)
            items.insert(item, at: 0)
            selectedItemID = item.id
            trimToLimit()
        }
        save()
    }

    /// User picked a history entry: make it current both in the UI and on the system pasteboard,
    /// so a plain Cmd+V immediately after pastes it.
    func selectAndCopyToClipboard(_ id: UUID) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        selectedItemID = id

        pasteboard.clearContents()
        switch item.content {
        case .text(let string):
            pasteboard.setString(string, forType: .string)
        case .image(let data):
            pasteboard.setData(data, forType: .png)
        }
    }

    func delete(_ id: UUID) {
        items.removeAll { $0.id == id }
        if selectedItemID == id {
            selectedItemID = items.first?.id
        }
        save()
    }

    func clearAll() {
        items.removeAll()
        selectedItemID = nil
        save()
    }

    private func trimToLimit() {
        if items.count > maxItems {
            items.removeLast(items.count - maxItems)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) else { return }
        items = decoded
        selectedItemID = items.first?.id
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
