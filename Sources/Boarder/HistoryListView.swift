import SwiftUI
import AppKit

struct HistoryListView: View {
    @ObservedObject var store: ClipboardHistoryStore

    var body: some View {
        VStack(spacing: 0) {
            Text("Boarder")
                .font(.headline)
                .padding(.top, 10)
                .padding(.bottom, 6)

            if store.items.isEmpty {
                Spacer()
                Text("Copy something to get started")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(store.items) { item in
                            HistoryRowView(item: item, isSelected: item.id == store.selectedItemID)
                                .contentShape(Rectangle())
                                .onTapGesture { store.selectAndCopyToClipboard(item.id) }
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        store.delete(item.id)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }

            Divider()

            HStack {
                Text("Click an item to copy it")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Clear") { store.clearAll() }
                    .disabled(store.items.isEmpty)
                Button("Quit") { NSApp.terminate(nil) }
            }
            .padding(10)
        }
        .frame(width: 320, height: 420)
    }
}
