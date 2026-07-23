import XCTest
@testable import Boarder

@MainActor
final class ClipboardHistoryStoreTests: XCTestCase {
    private var tempDir: URL!

    override func setUp() async throws {
        try await super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("BoarderTests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
        tempDir = nil
        try await super.tearDown()
    }

    private func makeStore(pasteboard: NSPasteboard = .withUniqueName()) -> ClipboardHistoryStore {
        ClipboardHistoryStore(storageDirectory: tempDir, pasteboard: pasteboard)
    }

    func testRecordingNewContentInsertsAtFront() {
        let store = makeStore()
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("first")))
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("second")))

        XCTAssertEqual(store.items.map(\.previewText), ["second", "first"])
        XCTAssertEqual(store.selectedItemID, store.items.first?.id)
    }

    func testRecordingDuplicateContentMovesExistingEntryToFrontWithoutDuplicating() {
        let store = makeStore()
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("first")))
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("second")))
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("first")))

        XCTAssertEqual(store.items.count, 2)
        XCTAssertEqual(store.items.map(\.previewText), ["first", "second"])
    }

    func testDeleteRemovesItemAndUpdatesSelection() throws {
        let store = makeStore()
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("first")))
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("second")))
        let selected = try XCTUnwrap(store.selectedItemID)

        store.delete(selected)

        XCTAssertFalse(store.items.contains { $0.id == selected })
        XCTAssertEqual(store.selectedItemID, store.items.first?.id)
    }

    func testClearAllEmptiesHistoryAndSelection() {
        let store = makeStore()
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("first")))

        store.clearAll()

        XCTAssertTrue(store.items.isEmpty)
        XCTAssertNil(store.selectedItemID)
    }

    func testHistoryPersistsAcrossStoreInstances() {
        let firstStore = makeStore()
        firstStore.recordNewPasteboardContent(PasteboardSnapshot(content: .text("persisted")))

        let secondStore = makeStore()
        XCTAssertEqual(secondStore.items.map(\.previewText), ["persisted"])
    }

    func testTrimsHistoryToFiftyItems() {
        let store = makeStore()
        for i in 0..<60 {
            store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("item \(i)")))
        }

        XCTAssertEqual(store.items.count, 50)
        XCTAssertEqual(store.items.first?.previewText, "item 59")
    }

    func testSelectAndCopyWritesToProvidedPasteboardOnly() throws {
        let scratchPasteboard = NSPasteboard.withUniqueName()
        defer { scratchPasteboard.releaseGlobally() }
        let store = makeStore(pasteboard: scratchPasteboard)
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("copy me")))
        let id = try XCTUnwrap(store.items.first?.id)

        store.selectAndCopyToClipboard(id)

        XCTAssertEqual(scratchPasteboard.string(forType: .string), "copy me")
    }

    func testSelectingEarlierItemAfterNewerCopyRestoresItForPaste() throws {
        let pasteboard = NSPasteboard.withUniqueName()
        defer { pasteboard.releaseGlobally() }
        let store = makeStore(pasteboard: pasteboard)

        // User selects "A" and copies it (Cmd+C); Boarder's watcher records it.
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("A")))
        let itemA = try XCTUnwrap(store.items.first)

        // User selects "B" and copies it (Cmd+C); the system pasteboard now holds "B".
        store.recordNewPasteboardContent(PasteboardSnapshot(content: .text("B")))

        // User picks "A" from the Boarder history list.
        store.selectAndCopyToClipboard(itemA.id)

        // A Cmd+V right now should paste "A", not "B".
        XCTAssertEqual(pasteboard.string(forType: .string), "A")
    }
}
