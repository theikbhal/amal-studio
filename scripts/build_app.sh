#!/usr/bin/env bash
# Builds dist/AmalStudio.app (with icon) from the Swift package.
set -euo pipefail
cd "$(dirname "$0")/.."

APP="AmalStudio"
NAME="Amal Studio"
OUT="dist/${APP}.app"

if ! command -v swift >/dev/null 2>&1; then
  echo "Swift not found. Run:  xcode-select --install   (then run this script again)"
  exit 1
fi

swift build -c release
BIN="$(swift build -c release --show-bin-path)/${APP}"

rm -rf "$OUT"
mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"
cp "$BIN" "$OUT/Contents/MacOS/${APP}"

ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s Assets/AppIcon.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) Assets/AppIcon.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$OUT/Contents/Resources/AppIcon.icns"

cat > "$OUT/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>${NAME}</string>
  <key>CFBundleDisplayName</key><string>${NAME}</string>
  <key>CFBundleIdentifier</key><string>com.local.amalstudio</string>
  <key>CFBundleExecutable</key><string>${APP}</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.lifestyle</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSScreenCaptureUsageDescription</key><string>Amal Studio records your screen when you press Record.</string>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$OUT" >/dev/null 2>&1 || true
echo "Built $OUT"
