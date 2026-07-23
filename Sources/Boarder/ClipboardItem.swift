import Foundation

struct ClipboardItem: Identifiable, Codable, Equatable {
    enum Content: Codable, Equatable {
        case text(String)
        case image(Data) // PNG-encoded
    }

    let id: UUID
    let date: Date
    let content: Content

    init(id: UUID = UUID(), date: Date = Date(), content: Content) {
        self.id = id
        self.date = date
        self.content = content
    }

    var previewText: String {
        switch content {
        case .text(let string):
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Empty text" : trimmed
        case .image:
            return "Image"
        }
    }

    func matches(_ otherContent: Content) -> Bool {
        content == otherContent
    }
}
