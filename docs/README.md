# Boarder

A lightweight macOS menu-bar clipboard history app. Boarder lives in the menu bar (no Dock
icon), watches the system pasteboard, and keeps the last 50 things you copied so you can paste
an earlier one without re-copying it.

## Features

- **Clipboard history** — the last 50 text and image copies, newest first, persisted to disk so
  history survives a relaunch.
- **Click to re-copy** — click any row to put that item back on the system clipboard; a plain
  `Cmd+V` right after pastes it. Re-copying an item that is already in history moves it to the
  front instead of duplicating it.
- **Copy as plain text** — hover a text row to reveal a clipboard button next to the trash icon
  (also on the right-click menu). It puts that item on the clipboard as plain text without
  dismissing the list, so you can keep browsing history. Hidden for image rows.
- **Row-hover delete** — hover a row to reveal a trash button; the selected row otherwise shows a
  checkmark. Delete is also on the right-click menu.
- **Clear** — empties the whole history.

## Usage

Click the surfboard icon in the menu bar to open the history popover. Copy something anywhere in
macOS and it appears at the top of the list.

## Architecture

Classic AppKit `NSStatusItem` + `NSPopover` hosting a SwiftUI view — chosen over SwiftUI's
`MenuBarExtra` for a real popover arrow, precise sizing, and reliable click-outside dismissal.

| File | Responsibility |
| --- | --- |
| `BoarderApp.swift` | `@main` entry point; sets `.accessory` activation policy (menu-bar only). |
| `AppDelegate.swift` | Wires up the store, watcher, and status-item controller on launch. |
| `PasteboardWatcher.swift` | Polls `NSPasteboard.general.changeCount` on a 0.4s timer (macOS has no push notification for clipboard changes); extracts plain text or PNG image data. |
| `ClipboardHistoryStore.swift` | Owns the `[ClipboardItem]` list, JSON persistence, the 50-item cap, and pasteboard writes (`selectAndCopyToClipboard`). |
| `ClipboardItem.swift` | The model: `id` / `date` / `.text` or `.image` content, plus preview text and equality. |
| `StatusItemController.swift` | Owns the status item (surfboard icon) and the popover. |
| `HistoryListView.swift` / `HistoryRowView.swift` | SwiftUI history list and rows. |
| `SurfboardIcon.swift` | Programmatic surfboard silhouette rendered as a template menu-bar image. |

Persistence lives at `~/Library/Application Support/Boarder/history.json`. Both the storage
directory and the `NSPasteboard` are injectable so tests use a scratch directory and a private
pasteboard instead of touching real user data or the system clipboard.

## Build & run

```sh
make build      # swift build (sandbox disabled)
make test       # swift test
make dev        # debug build, kill any running Boarder, relaunch — logs at /tmp/boarder-dev.log
make app        # release build + .app bundle + ad-hoc codesign (see Scripts/build_app.sh)
make clean
```

Requires a Swift 6 toolchain and macOS 13+.
