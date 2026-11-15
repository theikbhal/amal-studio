#!/usr/bin/env bash
# One command: build, move to /Applications, put a shortcut on the Desktop, launch.
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/build_app.sh

DEST="/Applications/Amal Studio.app"
echo "Installing to /Applications ..."
rm -rf "$DEST" 2>/dev/null || sudo rm -rf "$DEST"
cp -R dist/AmalStudio.app "$DEST" 2>/dev/null || sudo cp -R dist/AmalStudio.app "$DEST"

echo "Creating Desktop shortcut ..."
rm -f "$HOME/Desktop/Amal Studio" "$HOME/Desktop/Amal Studio alias" 2>/dev/null || true
osascript <<OSA
tell application "Finder"
  make new alias file to POSIX file "$DEST" at desktop
end tell
OSA
[ -e "$HOME/Desktop/Amal Studio alias" ] && mv "$HOME/Desktop/Amal Studio alias" "$HOME/Desktop/Amal Studio" || true

touch "$DEST"
echo "Done. Opening Amal Studio ..."
open -a "Amal Studio"
