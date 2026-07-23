import SwiftUI
import AppKit

struct HistoryRowView: View {
    let item: ClipboardItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            leadingIcon
                .frame(width: 24, height: 24)

            Text(item.previewText)
                .font(.callout)
                .lineLimit(2)
                .truncationMode(.tail)

            Spacer(minLength: 8)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .background(isSelected ? Color.blue.opacity(0.12) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    @ViewBuilder
    private var leadingIcon: some View {
        switch item.content {
        case .text:
            Image(systemName: "text.alignleft")
                .foregroundStyle(.secondary)
        case .image(let data):
            if let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
