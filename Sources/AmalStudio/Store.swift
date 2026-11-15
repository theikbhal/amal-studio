import Foundation
import CryptoKit
import UserNotifications

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var data = AppData()
    @Published var adminUnlocked = false

    private let ud = UserDefaults.standard
    private let dataKey = "amal.data.v1"
    private let pinKey = "amal.pin.hash"

    static let fmt: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func key(_ date: Date) -> String { fmt.string(from: date) }
    static func date(_ key: String) -> Date? { fmt.date(from: key) }

    init() {
        if let raw = ud.data(forKey: dataKey), let d = try? JSONDecoder().decode(AppData.self, from: raw) {
            data = d
        }
        normalize()
    }

    private func save() {
        if let raw = try? JSONEncoder().encode(data) { ud.set(raw, forKey: dataKey) }
    }

    var todayKey: String { Self.key(Date()) }

    // MARK: Targets, levels, counting

    func target(_ item: Item) -> Int { data.targets[item.id] ?? item.defaultTarget }

    func setTarget(_ v: Int, for item: Item) {
        data.targets[item.id] = max(1, v)
        save()
    }

    func level(on key: String) -> PassLevel { PassLevel(rawValue: data.levels[key] ?? 0) ?? .full }

    func setLevel(_ lv: PassLevel) {
        data.levels[todayKey] = lv.rawValue
        save()
    }

    func goal(_ item: Item, on key: String) -> Int {
        let lv = level(on: key)
        return lv == .full ? target(item) : min(lv.rawValue, target(item))
    }

    func count(_ item: Item, on key: String) -> Int { data.counts[key]?[item.id] ?? 0 }

    func add(_ n: Int, to item: Item) {
        let k = todayKey
        var day = data.counts[k] ?? [:]
        day[item.id] = max(0, (day[item.id] ?? 0) + n)
        data.counts[k] = day
        save()
    }

    func itemMet(_ item: Item, on key: String) -> Bool {
        count(item, on: key) >= max(1, goal(item, on: key))
    }

    var totalScore: Int { data.counts.values.reduce(0) { $0 + $1.values.reduce(0, +) } }
    var todayTotal: Int { data.counts[todayKey]?.values.reduce(0, +) ?? 0 }

    func total(for item: Item) -> Int { data.counts.values.reduce(0) { $0 + ($1[item.id] ?? 0) } }

    // MARK: Challenges

    var challenges: [Challenge] { data.challenges }

    func addChallenge(_ c: Challenge) {
        data.challenges.append(c)
        save()
    }

    func endChallenge(_ id: UUID) {
        guard let i = data.challenges.firstIndex(where: { $0.id == id }) else { return }
        data.challenges[i].endedOn = todayKey
        save()
    }

    func dayPassed(_ c: Challenge, _ key: String) -> Bool {
        guard !c.itemIDs.isEmpty else { return false }
        return c.itemIDs.allSatisfy { id in
            if let item = Content.item(id) { return itemMet(item, on: key) }
            return true
        }
    }

    func phase(of c: Challenge, on date: Date) -> Phase {
        let k = Self.key(date)
        if let e = c.endedOn, k >= e { return .completed }
        guard let sk = c.starts.last(where: { $0 <= k }), let start = Self.date(sk) else { return .notStarted }
        let cal = Calendar.current
        let off = cal.dateComponents([.day], from: cal.startOfDay(for: start), to: cal.startOfDay(for: date)).day ?? 0
        if off < 0 { return .notStarted }
        let len = max(1, c.lengthDays)
        let cycle = len + max(0, c.breakDays)
        if c.repeats {
            let r = off % cycle
            return r < len ? .active(day: r + 1, run: off / cycle + 1) : .rest(day: r - len + 1)
        }
        return off < len ? .active(day: off + 1, run: 1) : .completed
    }

    func phaseText(_ c: Challenge) -> String {
        switch phase(of: c, on: Date()) {
        case .notStarted:
            return "Starts on \(c.starts.last ?? "")"
        case .active(let day, let run):
            var s = "Day \(day) of \(c.lengthDays)"
            if c.repeats { s += " · run \(run)" }
            if c.starts.count > 1 { s += " · attempt \(c.starts.count)" }
            return s
        case .rest(let day):
            return "Rest day \(day) of \(c.breakDays). Your streak is safe."
        case .completed:
            return c.endedOn != nil ? "Ended" : "Completed ✓ Alhamdulillah"
        }
    }

    func isActive(_ c: Challenge) -> Bool {
        if case .active = phase(of: c, on: Date()) { return true }
        return false
    }

    func isRest(_ c: Challenge) -> Bool {
        if case .rest = phase(of: c, on: Date()) { return true }
        return false
    }

    var currentChallenges: [Challenge] {
        challenges.filter { c in
            switch phase(of: c, on: Date()) {
            case .active, .rest, .notStarted: return c.endedOn == nil
            case .completed: return false
            }
        }
    }

    var pastChallenges: [Challenge] {
        challenges.filter { c in
            if case .completed = phase(of: c, on: Date()) { return true }
            return false
        }
    }

    var activeItemIDs: Set<String> {
        var s = Set<String>()
        for c in challenges where isActive(c) { s.formUnion(c.itemIDs) }
        return s
    }

    /// Cells for the current (or last) run of a challenge.
    func runCells(_ c: Challenge) -> [(day: Int, state: CellState)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var startDate: Date?
        switch phase(of: c, on: today) {
        case .active(let day, _): startDate = cal.date(byAdding: .day, value: -(day - 1), to: today)
        case .rest(let day): startDate = cal.date(byAdding: .day, value: -(c.lengthDays + day - 1), to: today)
        case .completed: startDate = c.starts.last.flatMap { Self.date($0) }
        case .notStarted: startDate = nil
        }
        guard let start = startDate else { return [] }
        return (0..<c.lengthDays).compactMap { i in
            guard let d = cal.date(byAdding: .day, value: i, to: start) else { return nil }
            let passed = dayPassed(c, Self.key(d))
            if d > today { return (i + 1, .future) }
            if d == today { return (i + 1, passed ? .passed : .today) }
            return (i + 1, passed ? .passed : .missed)
        }
    }

    /// Strict challenges (chilla): if an active day was missed, restart the run from today.
    func normalize() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var changed = false
        for i in data.challenges.indices {
            let c = data.challenges[i]
            guard c.strict, c.endedOn == nil, let sk = c.starts.last, let s = Self.date(sk) else { continue }
            var d = cal.startOfDay(for: s)
            while d < today {
                if case .active = phase(of: c, on: d), !dayPassed(c, Self.key(d)) {
                    data.challenges[i].starts.append(Self.key(today))
                    changed = true
                    break
                }
                d = cal.date(byAdding: .day, value: 1, to: d) ?? today
            }
        }
        if changed { save() }
    }

    // MARK: Streaks

    func dayStatus(on date: Date) -> DayStatus {
        let k = Self.key(date)
        var anyActive = false, anyRest = false, allPass = true
        for c in data.challenges {
            switch phase(of: c, on: date) {
            case .active:
                anyActive = true
                if !dayPassed(c, k) { allPass = false }
            case .rest:
                anyRest = true
            default:
                break
            }
        }
        if anyActive { return allPass ? .pass : .fail }
        return anyRest ? .rest : .none
    }

    func status(of c: Challenge, on date: Date) -> DayStatus {
        switch phase(of: c, on: date) {
        case .active: return dayPassed(c, Self.key(date)) ? .pass : .fail
        case .rest: return .rest
        default: return .none
        }
    }

    private var earliestStart: Date? {
        data.challenges.flatMap { $0.starts }.min().flatMap { Self.date($0) }
    }

    func streak(_ statusFor: (Date) -> DayStatus) -> (current: Int, best: Int) {
        guard let first = earliestStart else { return (0, 0) }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var d = cal.startOfDay(for: first)
        var run = 0, best = 0
        while d <= today {
            switch statusFor(d) {
            case .pass:
                run += 1
                best = max(best, run)
            case .fail:
                if d != today { run = 0 }   // today is still in progress
            default:
                break
            }
            d = cal.date(byAdding: .day, value: 1, to: d) ?? today.addingTimeInterval(86_400)
        }
        return (run, best)
    }

    var overallStreak: (current: Int, best: Int) { streak { self.dayStatus(on: $0) } }

    func streak(of c: Challenge) -> (current: Int, best: Int) { streak { self.status(of: c, on: $0) } }

    var daysPassed: Int {
        guard let first = earliestStart else { return 0 }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var d = cal.startOfDay(for: first)
        var n = 0
        while d <= today {
            if dayStatus(on: d) == .pass { n += 1 }
            d = cal.date(byAdding: .day, value: 1, to: d) ?? today.addingTimeInterval(86_400)
        }
        return n
    }

    func recentDays(_ n: Int) -> [(label: String, status: DayStatus)] {
        let cal = Calendar.current
        let f = DateFormatter()
        f.dateFormat = "d"
        return (0..<n).reversed().compactMap { off in
            guard let d = cal.date(byAdding: .day, value: -off, to: Date()) else { return nil }
            return (f.string(from: d), dayStatus(on: d))
        }
    }

    // MARK: Text (with admin overrides)

    func variantIndex(_ item: Item) -> Int { min(data.variantChoice[item.id] ?? 0, item.variants.count - 1) }

    func setVariant(_ i: Int, for item: Item) {
        data.variantChoice[item.id] = i
        save()
    }

    func text(_ item: Item, _ index: Int) -> VariantText {
        data.overrides["\(item.id)#\(index)"] ?? item.variants[index].text
    }

    func isEdited(_ item: Item, _ index: Int) -> Bool { data.overrides["\(item.id)#\(index)"] != nil }

    func saveText(_ t: VariantText, item: Item, index: Int) {
        data.overrides["\(item.id)#\(index)"] = t
        save()
    }

    func resetText(item: Item, index: Int) {
        data.overrides["\(item.id)#\(index)"] = nil
        save()
    }

    func resetAllProgress() {
        data.counts = [:]
        data.levels = [:]
        data.challenges = []
        save()
    }

    // MARK: Admin PIN

    var hasPIN: Bool { ud.string(forKey: pinKey) != nil }

    private func hash(_ pin: String) -> String {
        SHA256.hash(data: Data(("amal-studio-" + pin).utf8)).map { String(format: "%02x", $0) }.joined()
    }

    func setPIN(_ pin: String) {
        ud.set(hash(pin), forKey: pinKey)
        adminUnlocked = true
    }

    func unlock(_ pin: String) -> Bool {
        if ud.string(forKey: pinKey) == hash(pin) {
            adminUnlocked = true
            return true
        }
        return false
    }

    func lock() { adminUnlocked = false }
}

enum Reminder {
    static func apply() {
        let ud = UserDefaults.standard
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["amal.daily"])
        guard ud.bool(forKey: "reminderOn") else { return }
        let minutes = ud.integer(forKey: "reminderMin")
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Amal Studio"
            content.body = "Your daily challenge is waiting. Even 1 time keeps the streak alive."
            var comps = DateComponents()
            comps.hour = minutes / 60
            comps.minute = minutes % 60
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            center.add(UNNotificationRequest(identifier: "amal.daily", content: content, trigger: trigger))
        }
    }
}
