#!/bin/bash
# Builds Boarder.app from the Swift package and ad-hoc signs it.
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="Boarder"
BUILD_CONFIG="release"
BIN_PATH=".build/${BUILD_CONFIG}/${APP_NAME}"
APP_BUNDLE="${APP_NAME}.app"

echo "Building ${APP_NAME} (${BUILD_CONFIG})..."
swift build -c "${BUILD_CONFIG}" --disable-sandbox

echo "Assembling ${APP_BUNDLE}..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
cp "${BIN_PATH}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

echo "Generating app icon..."
ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
swift Scripts/generate_app_icon.swift "${ICONSET_DIR}"
iconutil -c icns "${ICONSET_DIR}" -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
rm -rf "$(dirname "${ICONSET_DIR}")"

cat > "${APP_BUNDLE}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.boarder.app</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1</string>
    <key>CFBundleVersion</key>
    <string>2</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Code-signing (ad-hoc)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo
echo "Done: ${APP_BUNDLE}"
echo "Drag it into /Applications, or just run: open ${APP_BUNDLE}"
echo "Note: this is ad-hoc signed for running on THIS Mac only. Copying it to another"
echo "machine will hit Gatekeeper (needs a paid Developer ID + notarization to fix)."
