import SwiftUI
import AppKit

// MARK: - Streaks

struct StreaksView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        let overall = store.overallStreak
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 14) {
                    card("Current streak", "\(overall.current)", "flame.fill", .orange)
                    card("Best streak", "\(overall.best)", "trophy.fill", .yellow)
                    card("Total score", store.totalScore.formatted(), "star.fill", .blue)
                    card("Days passed", "\(store.daysPassed)", "checkmark.seal.fill", .green)
                }

                GroupBox("Last 42 days") {
                    let days = store.recentDays(42)
                    VStack(alignment: .leading, spacing: 8) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                            ForEach(Array(days.enumerated()), id: \.offset) { _, d in
                                Text(d.label).font(.caption)
                                    .frame(maxWidth: .infinity, minHeight: 32)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(color(d.status)))
                            }
                        }
                        Text("Green = passed, red = missed, blue = rest day, gray = no challenge").font(.caption2).foregroundStyle(.secondary)
                    }
                    .padding(8)
                }

                GroupBox("Each challenge") {
                    VStack(spacing: 0) {
                        if store.challenges.isEmpty {
                            Text("No challenges yet.").foregroundStyle(.secondary).padding(8)
                        }
                        ForEach(store.challenges) { c in
                            let s = store.streak(of: c)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(c.name).font(.headline)
                                    Text(store.phaseText(c)).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("Streak \(s.current) · Best \(s.best)").monospacedDigit()
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                    .padding(8)
                }

                Text("A day passes when every active challenge reaches the pass level. Rest days never break a streak.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(24)
        }
    }

    private func color(_ s: DayStatus) -> Color {
        switch s {
        case .pass: return .green.opacity(0.55)
        case .fail: return .red.opacity(0.45)
        case .rest: return .blue.opacity(0.40)
        case .none: return .secondary.opacity(0.15)
        }
    }

    private func card(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title).foregroundStyle(color)
            Text(value).font(.system(size: 32, weight: .bold, design: .rounded)).minimumScaleFactor(0.6).lineLimit(1)
            Text(title).font(.callout).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(0.1)))
    }
}

// MARK: - Library (with admin editing)

struct EditTarget: Identifiable {
    let id = UUID()
    let item: Item
    let index: Int
}

struct LibraryView: View {
    @EnvironmentObject var store: AppStore
    @State private var editing: EditTarget?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Library").font(.largeTitle.bold())
                    Spacer()
                    if store.adminUnlocked {
                        Label("Admin mode", systemImage: "lock.open.fill").foregroundStyle(.orange)
                    }
                }
                Text("Arabic, Telugu and English letters with the benefit of each dhikr. Turn on Admin mode in Settings to edit the text.")
                    .font(.callout).foregroundStyle(.secondary)

                textCard(title: "Third Kalima (Tamjeed)", t: Content.thirdKalima, edited: false, onEdit: nil)

                ForEach(Content.items) { it in
                    HStack {
                        Text(it.name).font(.title2.bold())
                        Spacer()
                        if store.adminUnlocked {
                            Stepper("Daily target: \(store.target(it))",
                                    value: Binding(get: { store.target(it) }, set: { store.setTarget($0, for: it) }),
                                    in: 1...5000, step: 10)
                                .frame(maxWidth: 280)
                        }
                    }
                    .padding(.top, 10)
                    ForEach(Array(it.variants.enumerated()), id: \.offset) { i, v in
                        textCard(title: v.name, t: store.text(it, i), edited: store.isEdited(it, i),
                                 onEdit: store.adminUnlocked ? { editing = EditTarget(item: it, index: i) } : nil)
                    }
                }

                Text("This app is a study aid, not a source of fatwa. Please confirm hadith gradings and rulings with your teacher.")
                    .font(.caption).foregroundStyle(.secondary).padding(.top, 8)
            }
            .padding(24)
        }
        .sheet(item: $editing) { target in EditSheet(target: target) }
    }

    private func textCard(title: String, t: VariantText, edited: Bool, onEdit: (() -> Void)?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.headline)
                if edited { Text("edited").font(.caption).padding(.horizontal, 6).background(Capsule().fill(Color.orange.opacity(0.3))) }
                Spacer()
                if let onEdit { Button("Edit", action: onEdit) }
            }
            Text(t.arabic).font(.custom("Geeza Pro", size: 30))
                .environment(\.layoutDirection, .rightToLeft)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(t.telugu).font(.title3)
            Text(t.english).italic()
            Text(t.meaning).foregroundStyle(.secondary)
            Divider()
            Text("Benefit: " + t.virtue)
            Text(t.source).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
    }
}

struct EditSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let target: EditTarget
    @State private var draft = VariantText(arabic: "", telugu: "", english: "", meaning: "", virtue: "", source: "")

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit: \(target.item.name) · \(target.item.variants[target.index].name)").font(.title2.bold())
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    field("Arabic", $draft.arabic, 60, rtl: true)
                    field("Telugu", $draft.telugu, 60)
                    field("English letters", $draft.english, 60)
                    field("Meaning", $draft.meaning, 60)
                    field("Benefit", $draft.virtue, 100)
                    field("Source", $draft.source, 60)
                }
            }
            HStack {
                Button("Reset to original", role: .destructive) {
                    store.resetText(item: target.item, index: target.index)
                    dismiss()
                }
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    store.saveText(draft, item: target.item, index: target.index)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(minWidth: 620, minHeight: 640)
        .onAppear { draft = store.text(target.item, target.index) }
    }

    private func field(_ label: String, _ text: Binding<String>, _ height: CGFloat, rtl: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextEditor(text: text)
                .font(rtl ? .custom("Geeza Pro", size: 22) : .body)
                .environment(\.layoutDirection, rtl ? .rightToLeft : .leftToRight)
                .frame(height: height)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.1)))
        }
    }
}

// MARK: - Help (docs, roadmap, AI prompt)

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Help").font(.largeTitle.bold())
                ForEach(Array(Content.help.enumerated()), id: \.offset) { _, h in
                    DisclosureGroup {
                        Text(h.1).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
                    } label: { Text(h.0).font(.headline) }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.1)))
                }

                Text("Roadmap").font(.title2.bold()).padding(.top, 12)
                ForEach(Array(Content.roadmap.enumerated()), id: \.offset) { _, r in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(r.0).font(.headline)
                        Text(r.1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.1)))
                }

                Text("AI prompt used").font(.title2.bold()).padding(.top, 12)
                Text("This app was created with Claude (by Anthropic) from the prompt below.")
                    .font(.callout).foregroundStyle(.secondary)
                Text(Content.aiPrompt)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.1)))
                Button("Copy prompt") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(Content.aiPrompt, forType: .string)
                }
                Text("Source code and docs: docs/ folder in the GitHub repository.").font(.caption).foregroundStyle(.secondary)
            }
            .padding(24)
        }
    }
}

// MARK: - Settings

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @AppStorage("appearance") private var appearance = "system"
    @AppStorage("haptics") private var haptics = true
    @AppStorage("reminderOn") private var reminderOn = false
    @AppStorage("reminderMin") private var reminderMin = 20 * 60
    @State private var showPin = false
    @State private var confirmReset = false

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Mode", selection: $appearance) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
                Toggle("Trackpad haptic feedback when counting", isOn: $haptics)
            }

            Section("Admin mode (edit dhikr text)") {
                HStack {
                    Text(store.adminUnlocked ? "Admin mode is ON" : "Admin mode is OFF")
                    Spacer()
                    if store.adminUnlocked {
                        Button("Turn off") { store.lock() }
                    } else {
                        Button(store.hasPIN ? "Unlock…" : "Set PIN and unlock…") { showPin = true }
                    }
                }
                Text("Admin mode lets you edit the Arabic, Telugu, English letters, meaning, benefit, source and daily targets in the Library.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Daily reminder") {
                Toggle("Remind me every day", isOn: $reminderOn)
                DatePicker("Time", selection: timeBinding($reminderMin), displayedComponents: .hourAndMinute)
                    .disabled(!reminderOn)
            }

            Section("Recordings") {
                Text("Saved to: \(ScreenRecorder.outputDir.path)").font(.caption).textSelection(.enabled)
                Button("Open recordings folder") {
                    try? FileManager.default.createDirectory(at: ScreenRecorder.outputDir, withIntermediateDirectories: true)
                    NSWorkspace.shared.open(ScreenRecorder.outputDir)
                }
            }

            Section("Data") {
                Button("Reset all progress and challenges…", role: .destructive) { confirmReset = true }
            }
        }
        .formStyle(.grouped)
        .padding(12)
        .onChange(of: reminderOn) { _ in Reminder.apply() }
        .onChange(of: reminderMin) { _ in Reminder.apply() }
        .sheet(isPresented: $showPin) { PinSheet() }
        .confirmationDialog("Delete all counts, streaks and challenges? Your edited text is kept.", isPresented: $confirmReset) {
            Button("Delete everything", role: .destructive) { store.resetAllProgress() }
        }
    }

    private func timeBinding(_ minutes: Binding<Int>) -> Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: minutes.wrappedValue / 60,
                                      minute: minutes.wrappedValue % 60, second: 0, of: Date()) ?? Date()
            },
            set: { newValue in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                minutes.wrappedValue = (c.hour ?? 0) * 60 + (c.minute ?? 0)
            }
        )
    }
}

struct PinSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var pin = ""
    @State private var confirm = ""
    @State private var error = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.hasPIN ? "Enter admin PIN" : "Set an admin PIN").font(.title2.bold())
            SecureField("PIN (at least 4 characters)", text: $pin)
            if !store.hasPIN { SecureField("Repeat PIN", text: $confirm) }
            if !error.isEmpty { Text(error).foregroundStyle(.red).font(.caption) }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button(store.hasPIN ? "Unlock" : "Set PIN") { submit() }.buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private func submit() {
        if store.hasPIN {
            if store.unlock(pin) { dismiss() } else { error = "Wrong PIN." }
        } else {
            guard pin.count >= 4 else { error = "Use at least 4 characters."; return }
            guard pin == confirm else { error = "The two PINs do not match."; return }
            store.setPIN(pin)
            dismiss()
        }
    }
}
