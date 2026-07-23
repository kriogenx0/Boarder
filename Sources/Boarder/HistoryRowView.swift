import SwiftUI
import AppKit

struct HistoryRowView: View {
    let item: ClipboardItem
    let isSelected: Bool

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            rowContent

            Spacer(minLength: 8)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(isHovered ? 0.18 : 0.12)
        } else if isHovered {
            return Color.primary.opacity(0.06)
        } else {
            return Color.clear
        }
    }

    @ViewBuilder
    private var rowContent: some View {
        switch item.content {
        case .text:
            Text(item.previewText)
                .font(.callout)
                .lineLimit(2)
                .truncationMode(.tail)
        case .image(let data):
            if let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(item.previewText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
