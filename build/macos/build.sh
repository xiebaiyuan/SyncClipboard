#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../../src"
APP_NAME="KittyHappy"
PROJECT="SyncClipboard.Desktop.MacOS/SyncClipboard.Desktop.MacOS.csproj"
RID="osx-arm64"

echo "=== Building $APP_NAME ==="

# Build
cd "$SRC_DIR"
dotnet build "$PROJECT" -r "$RID" -c Debug

# Paths
BUILD_APP="$SRC_DIR/SyncClipboard.Desktop.MacOS/bin/Debug/net9.0-macos/$RID/SyncClipboard.Desktop.MacOS.app"
OUTPUT_DIR="$SRC_DIR/SyncClipboard.Desktop.MacOS/bin/Debug/net9.0-macos/$RID"
FINAL_APP="$OUTPUT_DIR/$APP_NAME.app"

# Copy assets
echo "=== Copying Info.plist and icon ==="
/bin/cp -f "$SCRIPT_DIR/Info.plist" "$BUILD_APP/Contents/Info.plist"
/bin/cp -f "$SCRIPT_DIR/icon.icns" "$BUILD_APP/Contents/Resources/icon.icns" 2>/dev/null || true

# Rename
echo "=== Renaming to $APP_NAME.app ==="
/bin/rm -rf "$FINAL_APP" 2>/dev/null || true
/bin/mv "$BUILD_APP" "$FINAL_APP"

# Re-sign
echo "=== Code signing ==="
codesign --force --deep --sign - "$FINAL_APP"

# Zip
echo "=== Creating zip ==="
cd "$OUTPUT_DIR"
/bin/rm -f "$APP_NAME.zip" 2>/dev/null || true
zip -r "$APP_NAME.zip" "$APP_NAME.app"

echo ""
echo "=== Done ==="
echo "App: $FINAL_APP"
echo "Zip: $OUTPUT_DIR/$APP_NAME.zip"
echo "Size: $(du -sh "$FINAL_APP" | cut -f1)"
