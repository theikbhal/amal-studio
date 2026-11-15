import Foundation

// MARK: - Dhikr content

struct VariantText: Codable, Equatable {
    var arabic: String
    var telugu: String
    var english: String      // English letters (transliteration)
    var meaning: String
    var virtue: String
    var source: String
}

struct Variant {
    let name: String
    let text: VariantText
}

struct Item: Identifiable {
    let id: String
    let name: String
    let icon: String
    let defaultTarget: Int
    let variants: [Variant]
}

// MARK: - Challenges

struct Challenge: Codable, Identifiable {
    var id = UUID()
    var name: String
    var lengthDays: Int
    var itemIDs: [String]
    var starts: [String]          // run start keys (yyyy-MM-dd). First = original start, later = strict restarts
    var repeats: Bool             // mini repeating challenge
    var breakDays: Int            // rest days between runs
    var strict: Bool              // missing a day restarts the run (like a 40-day chilla)
    var endedOn: String? = nil
}

enum Phase {
    case notStarted
    case active(day: Int, run: Int)
    case rest(day: Int)
    case completed
}

enum DayStatus { case pass, fail, rest, none }

enum CellState { case passed, missed, today, future }

/// "Minimum pass mode": on a hard day lower the bar for every sub-challenge.
enum PassLevel: Int, CaseIterable, Identifiable {
    case full = 0, thirty = 30, three = 3, one = 1
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .full: return "Full"
        case .thirty: return "30"
        case .three: return "3 times"
        case .one: return "1 time"
        }
    }
}

struct ChallengePreset: Identifiable {
    let id: String
    let name: String
    let blurb: String
    let lengthDays: Int
    let itemIDs: [String]
    let repeats: Bool
    let breakDays: Int
    let strict: Bool
}

struct AppData: Codable {
    var counts: [String: [String: Int]] = [:]   // dateKey -> itemID -> count
    var levels: [String: Int] = [:]             // dateKey -> PassLevel rawValue
    var challenges: [Challenge] = []
    var overrides: [String: VariantText] = [:]  // "itemID#variantIndex" -> admin-edited text
    var targets: [String: Int] = [:]
    var variantChoice: [String: Int] = [:]
}

// MARK: - Screen recording presets

enum CaptureKind: String { case video, image }

struct RecordPreset: Identifiable, Hashable {
    let id: String
    let name: String
    let platform: String
    let ratio: String
    let width: Int
    let height: Int
    let fps: Int
    let kind: CaptureKind
    let icon: String
}

enum Presets {
    static let all: [RecordPreset] = [
        RecordPreset(id: "reel", name: "Instagram Reel", platform: "Instagram", ratio: "9:16", width: 1080, height: 1920, fps: 30, kind: .video, icon: "play.rectangle.fill"),
        RecordPreset(id: "igpost", name: "Instagram Image Post", platform: "Instagram", ratio: "4:5", width: 1080, height: 1350, fps: 1, kind: .image, icon: "photo.fill"),
        RecordPreset(id: "short", name: "YouTube Short", platform: "YouTube", ratio: "9:16", width: 1080, height: 1920, fps: 30, kind: .video, icon: "bolt.fill"),
        RecordPreset(id: "ytvideo", name: "YouTube Video", platform: "YouTube", ratio: "16:9", width: 1920, height: 1080, fps: 30, kind: .video, icon: "play.tv.fill"),
        RecordPreset(id: "xvideo", name: "X (Twitter) Video", platform: "X", ratio: "16:9", width: 1280, height: 720, fps: 30, kind: .video, icon: "video.fill"),
        RecordPreset(id: "ximage", name: "X (Twitter) Image Post", platform: "X", ratio: "16:9", width: 1600, height: 900, fps: 1, kind: .image, icon: "photo.on.rectangle")
    ]
}
