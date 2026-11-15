# Amal Studio Help

## Install
1. `./scripts/install.sh` builds the app, copies it to `/Applications`, creates a Desktop shortcut and opens it.
2. If macOS blocks the first launch: right-click the app, choose **Open**, then **Open**.
3. Build errors: `xcode-select --install`, then run the script again.

## Today
Pick a sub-challenge on the left. **Space** or click the ring counts one. **+10** adds ten. **⌘Z** undoes one.
Each dhikr shows Arabic, Telugu, English letters, meaning and benefit.

## Challenges
Press **New challenge**. Start from a preset or build your own: length, sub-challenges, start date, repeat, break days, strict.
- **Mini repeating challenge:** runs, rests for the break days, then repeats.
- **Strict (chilla):** missing a day restarts the run from today. History is kept.
- **Not strict:** missed days are marked red and the challenge continues.
- **Rest days** never break a streak.

## Minimum pass mode
Set the pass level for today to **Full**, **30**, **3 times** or **1 time**. A day passes when every sub-challenge in each active challenge reaches that level.

## Streaks and score
- Overall streak: consecutive passed days (rest days are skipped).
- Each challenge has its own streak and best streak.
- Total score = every repetition ever counted.

## Library and admin mode
Settings → Admin mode → set a PIN → unlock. In the Library you can edit Arabic, Telugu, English letters, meaning, benefit, source and the daily target of each dhikr. **Reset to original** undoes any edit.
The PIN is stored as a hash on your Mac. If you forget it, delete the app's preferences: `defaults delete com.local.amalstudio`.

## Record
1. Choose a preset: Instagram Reel (1080x1920), Instagram image post (1080x1350), YouTube Short (1080x1920), YouTube video (1920x1080), X video (1280x720), X image post (1600x900), or Custom.
2. Adjust **Size**, **Left to right**, **Top to bottom**. Turn on **Show the capture frame** to see the red border on your screen.
3. Choose a start delay, then **Start recording** (or **Take image** for image presets).
4. Stop from the app or from the menu bar icon.
5. Files go to `~/Movies/AmalStudio`.

Notes: v1 records the main display, video only (no audio). Amal Studio's own windows are hidden from the recording unless you turn on "Include Amal Studio's own windows".

## Screen Recording permission
System Settings → Privacy & Security → Screen Recording → enable Amal Studio, then quit and reopen. After rebuilding the app macOS may ask again: remove Amal Studio from the list, add it back, and reopen.

## Privacy
Everything stays on your Mac. The app does not use the internet.
