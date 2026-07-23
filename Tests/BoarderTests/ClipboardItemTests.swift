import XCTest
@testable import Boarder

final class ClipboardItemTests: XCTestCase {
    func testMatchesSameText() {
        let item = ClipboardItem(content: .text("hello"))
        XCTAssertTrue(item.matches(.text("hello")))
    }

    func testDoesNotMatchDifferentText() {
        let item = ClipboardItem(content: .text("hello"))
        XCTAssertFalse(item.matches(.text("goodbye")))
    }

    func testDoesNotMatchAcrossContentTypes() {
        let item = ClipboardItem(content: .text("hello"))
        XCTAssertFalse(item.matches(.image(Data([0x01, 0x02]))))
    }

    func testPreviewTextTrimsWhitespace() {
        let item = ClipboardItem(content: .text("  padded  \n"))
        XCTAssertEqual(item.previewText, "padded")
    }

    func testPreviewTextForBlankStringIsPlaceholder() {
        let item = ClipboardItem(content: .text("   "))
        XCTAssertEqual(item.previewText, "Empty text")
    }

    func testPreviewTextForImageIsPlaceholder() {
        let item = ClipboardItem(content: .image(Data([0x01])))
        XCTAssertEqual(item.previewText, "Image")
    }
}
