import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject var store: AppStore
    @State private var showNew = false
    @State private var confirmEnd: Challenge?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Challenges").font(.largeTitle.bold())
                    Spacer()
                    Button { showNew = true } label: { Label("New challenge", systemImage: "plus") }
                        .buttonStyle(.borderedProminent).controlSize(.large)
                }
                Text("Each challenge has sub-challenges (the dhikr). A day passes when every sub-challenge reaches today's pass level.")
                    .font(.callout).foregroundStyle(.secondary)

                if store.currentChallenges.isEmpty {
                    Text("No active challenge. Press New challenge and start with a preset (Mini 3-Day, 40-Day Chilla or 120-Day Journey).")
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
                }
                ForEach(store.currentChallenges) { c in card(c) }

                if !store.pastChallenges.isEmpty {
                    Text("Past challenges").font(.title3.bold()).padding(.top, 8)
                    ForEach(store.pastChallenges) { c in card(c) }
                }
            }
            .padding(24)
        }
        .sheet(isPresented: $showNew) { NewChallengeSheet() }
        .confirmationDialog("End this challenge? Your history is kept.", isPresented: Binding(
            get: { confirmEnd != nil }, set: { if !$0 { confirmEnd = nil } })) {
            Button("End challenge", role: .destructive) {
                if let c = confirmEnd { store.endChallenge(c.id) }
                confirmEnd = nil
            }
        }
    }

    @ViewBuilder
    private func card(_ c: Challenge) -> some View {
        let names = c.itemIDs.compactMap { Content.item($0)?.name }.joined(separator: ", ")
        let cells = store.runCells(c)
        let s = store.streak(of: c)
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(c.name).font(.title3.bold())
                    Text(store.phaseText(c)).foregroundStyle(.secondary)
                }
                Spacer()
                if c.endedOn == nil, store.pastChallenges.contains(where: { $0.id == c.id }) == false {
                    Button("End", role: .destructive) { confirmEnd = c }
                }
            }
            Text("\(c.lengthDays) days · " + (c.repeats ? "repeats, \(c.breakDays) break day(s)" : "single run") + (c.strict ? " · strict" : ""))
                .font(.caption).foregroundStyle(.secondary)
            Text("Sub-challenges: \(names)").font(.callout)
            Text("Streak \(s.current) · best \(s.best)").font(.callout.bold())

            if !cells.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 34), spacing: 6)], spacing: 6) {
                    ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                        Text("\(cell.day)")
                            .font(.caption2)
                            .frame(width: 34, height: 30)
                            .background(RoundedRectangle(cornerRadius: 6).fill(color(cell.state)))
                    }
                }
                Text("Green = passed, red = missed, blue = today, gray = upcoming").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
    }

    private func color(_ s: CellState) -> Color {
        switch s {
        case .passed: return .green.opacity(0.55)
        case .missed: return .red.opacity(0.45)
        case .today: return .blue.opacity(0.45)
        case .future: return .secondary.opacity(0.15)
        }
    }
}

struct NewChallengeSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = "My Challenge"
    @State private var length = 40
    @State private var ids: Set<String> = Set(Content.items.map { $0.id })
    @State private var repeats = false
    @State private var breakDays = 1
    @State private var strict = false
    @State private var start = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("New challenge").font(.title.bold())

            Text("Start from a preset").font(.headline)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Content.challengePresets) { p in
                        Button(p.name) { apply(p) }.buttonStyle(.bordered).help(p.blurb)
                    }
                }
            }

            Form {
                TextField("Name", text: $name)
                HStack {
                    Stepper("Length: \(length) days", value: $length, in: 1...365)
                    Button("3") { length = 3 }
                    Button("40") { length = 40 }
                    Button("120") { length = 120 }
                }
                DatePicker("Start date", selection: $start, displayedComponents: .date)
                Toggle("Repeat automatically (mini repeating challenge)", isOn: $repeats)
                if repeats {
                    Stepper("Break between runs: \(breakDays) day(s)", value: $breakDays, in: 0...7)
                }
                Toggle("Strict: missing a day restarts the run", isOn: $strict)

                Section("Sub-challenges") {
                    ForEach(Content.items) { it in
                        Toggle(it.name, isOn: Binding(
                            get: { ids.contains(it.id) },
                            set: { if $0 { ids.insert(it.id) } else { ids.remove(it.id) } }))
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Start challenge") { create() }
                    .buttonStyle(.borderedProminent)
                    .disabled(ids.isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(minWidth: 560, minHeight: 640)
    }

    private func apply(_ p: ChallengePreset) {
        name = p.name
        length = p.lengthDays
        ids = Set(p.itemIDs)
        repeats = p.repeats
        breakDays = max(p.breakDays, p.repeats ? 1 : 0)
        strict = p.strict
    }

    private func create() {
        let c = Challenge(
            name: name.trimmingCharacters(in: .whitespaces),
            lengthDays: length,
            itemIDs: Content.items.map { $0.id }.filter { ids.contains($0) },
            starts: [AppStore.key(start)],
            repeats: repeats,
            breakDays: repeats ? breakDays : 0,
            strict: strict)
        store.addChallenge(c)
        dismiss()
    }
}
