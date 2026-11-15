#!/usr/bin/env bash
# Creates the GitHub repo and pushes. Needs:  brew install gh && gh auth login
set -euo pipefail
cd "$(dirname "$0")/.."

REPO="${1:-amal-studio}"
[ -d .git ] || git init -b main
git add .
git commit -m "Amal Studio: daily challenges, streaks, dhikr library and screen recording presets" || true
gh repo create "$REPO" --public --source=. --remote=origin --push
echo "Pushed. Open it with:  gh repo view --web"
