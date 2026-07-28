import SwiftUI
import AppKit

struct HistoryRowView: View {
    let item: ClipboardItem
    let isSelected: Bool
    let onDelete: () -> Void

    @State private var isHovered = false

    private let trailingAccessorySize: CGFloat = 20

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 8) {
                rowContent
                Spacer(minLength: trailingAccessorySize)
            }

            trailingAccessory
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

    @ViewBuilder
    private var trailingAccessory: some View {
        if isHovered {
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .frame(width: trailingAccessorySize, height: trailingAccessorySize)
        } else if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.blue)
                .frame(width: trailingAccessorySize, height: trailingAccessorySize)
        } else {
            Color.clear
                .frame(width: trailingAccessorySize, height: trailingAccessorySize)
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
