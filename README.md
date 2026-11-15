# Amal Studio

A native macOS app (Swift / SwiftUI) that combines:
1. **Daily challenges** (3-day, 40-day, 120-day, and mini repeating challenges with break days) built from sub-challenges (dhikr).
2. A built-in **dhikr library** in Arabic, Telugu and English letters, with the benefit of each.
3. **Streaks**, a total score, and a **minimum pass mode** (3 times or 1 time).
4. A **screen recorder** with presets for Instagram Reel, Instagram image post, YouTube Short, YouTube video and X (Twitter) video/image posts. It records any screen, not only this app.

> Started 15 November 2026. Small, steady, consistent.

## Sub-challenges (each 100 by default, editable)
Subhanallah (and Subhanallahi wa bihamdihi), Alhamdulillah, La ilaha illallah, Allahu Akbar, La hawla wa la quwwata illa billah (these five are the Third Kalima), Darood (including Jazallahu anna Muhammadan), and Astaghfirullah (including the full istighfar).

## Challenge presets
| Preset | Length | Rules |
|---|---|---|
| Mini 3-Day: Third Kalima | 3 days | repeats, 1 break day |
| Mini 3-Day: Durood + Istighfar | 3 days | repeats, 1 break day |
| 40-Day Chilla | 40 days | strict: a missed day restarts |
| 120-Day Journey | 120 days | missed days do not reset |

## Install (Mac, one command)
Requires macOS 13+ and Xcode (or `xcode-select --install`).
```bash
git clone https://github.com/theikbhal/amal-studio.git
cd amal-studio
./scripts/install.sh
```
Builds the app, moves it to **/Applications**, adds a **Desktop shortcut**, and opens it.
Or open `Package.swift` in Xcode and press Run.

## Screen recording permission
macOS asks for Screen Recording permission the first time. Allow it, then quit and reopen the app.
Recordings are saved to `~/Movies/AmalStudio`.

## Docs
- [Help](docs/HELP.md)
- [AI prompt used](docs/AI_PROMPT.md)
- [Roadmap](docs/ROADMAP.md)
- [Content and sources](docs/CONTENT.md)

This app is a study aid, not a source of fatwa. Please verify hadith gradings with your teacher.
