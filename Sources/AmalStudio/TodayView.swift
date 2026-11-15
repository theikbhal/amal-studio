import SwiftUI
import AppKit

struct RingView: View {
    let progress: Double
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle().stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.2), value: progress)
        }
    }
}

struct TodayView: View {
    @EnvironmentObject var store: AppStore
    @AppStorage("haptics") private var haptics = true
    @State private var selectedID = Content.items[0].id

    private var item: Item { Content.item(selectedID) ?? Content.items[0] }
    private var key: String { store.todayKey }

    var body: some View {
        VStack(spacing: 0) {
            summaryBar
            Divider()
            HStack(spacing: 0) {
                sidebar.frame(width: 300)
                Divider()
                detail
            }
        }
    }

    // MARK: Summary

    private var summaryBar: some View {
        HStack(spacing: 32) {
            stat("Total score", store.totalScore.formatted())
            stat("Today", store.todayTotal.formatted())
            stat("Streak", "\(store.overallStreak.current) 🔥")
            stat("Challenges", "\(store.currentChallenges.count)")
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.title2.bold()).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }

    // MARK: Sidebar

    private var sidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's challenges").font(.headline)
                if store.currentChallenges.isEmpty {
                    Text("No challenge yet. Open the Challenges tab and start one.")
                        .font(.callout).foregroundStyle(.secondary)
                }
                ForEach(store.currentChallenges) { c in challengeCard(c) }

                Text("Sub-challenges").font(.headline).padding(.top, 8)
                ForEach(Content.items) { it in itemRow(it) }
            }
            .padding(12)
        }
    }

    @ViewBuilder
    private func challengeCard(_ c: Challenge) -> some View {
        let done = c.itemIDs.compactMap { Content.item($0) }.filter { store.itemMet($0, on: key) }.count
        VStack(alignment: .leading, spacing: 4) {
            Text(c.name).font(.subheadline.bold())
            Text(store.phaseText(c)).font(.caption).foregroundStyle(.secondary)
            if store.isActive(c) {
                ProgressView(value: Double(done), total: Double(max(c.itemIDs.count, 1)))
                Text("\(done) of \(c.itemIDs.count) sub-challenges done today").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.10)))
    }

    @ViewBuilder
    private func itemRow(_ it: Item) -> some View {
        let c = store.count(it, on: key)
        let g = max(1, store.goal(it, on: key))
        let inChallenge = store.activeItemIDs.contains(it.id)
        Button { selectedID = it.id } label: {
            HStack(spacing: 10) {
                ZStack {
                    RingView(progress: Double(c) / Double(g), lineWidth: 4)
                    Image(systemName: it.icon).font(.caption)
                }
                .frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(it.name).font(.headline).lineLimit(1)
                    Text("\(c) / \(g)").font(.caption).foregroundStyle(.secondary).monospacedDigit()
                }
                Spacer()
                if inChallenge { Image(systemName: "flag.fill").font(.caption).foregroundStyle(.orange) }
                if c >= g { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedID == it.id ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Detail

    private var detail: some View {
        let it = item
        let count = store.count(it, on: key)
        let goal = max(1, store.goal(it, on: key))
        let vi = store.variantIndex(it)
        let t = store.text(it, vi)

        return ScrollView {
            VStack(spacing: 14) {
                dayBanner

                Text(it.name).font(.title.bold())

                if it.variants.count > 1 {
                    Picker("", selection: Binding(get: { store.variantIndex(it) }, set: { store.setVariant($0, for: it) })) {
                        ForEach(Array(it.variants.enumerated()), id: \.offset) { i, v in Text(v.name).tag(i) }
                    }
                    .pickerStyle(.segmented).labelsHidden().frame(maxWidth: 620)
                }

                Text(t.arabic)
                    .font(.custom("Geeza Pro", size: 52))
                    .minimumScaleFactor(0.4)
                    .multilineTextAlignment(.center)
                    .environment(\.layoutDirection, .rightToLeft)
                Text(t.telugu).font(.title2).multilineTextAlignment(.center)
                Text(t.english).font(.title3).italic().multilineTextAlignment(.center)
                Text(t.meaning).foregroundStyle(.secondary).multilineTextAlignment(.center)

                ZStack {
                    RingView(progress: Double(count) / Double(goal), lineWidth: 16).frame(width: 200, height: 200)
                    VStack(spacing: 2) {
                        Text("\(count)").font(.system(size: 50, weight: .bold, design: .rounded)).monospacedDigit()
                        Text("of \(goal)").foregroundStyle(.secondary).monospacedDigit()
                    }
                }
                .contentShape(Circle())
                .onTapGesture { tap(it, 1) }

                if count >= goal {
                    Label("\(it.name) done for today. Alhamdulillah.", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green).font(.headline)
                }

                HStack(spacing: 12) {
                    Button { store.add(-1, to: it) } label: { Label("Undo", systemImage: "arrow.uturn.backward") }
                        .keyboardShortcut("z", modifiers: .command)
                    Button { tap(it, 1) } label: { Label("Count", systemImage: "plus.circle.fill").frame(minWidth: 140) }
                        .buttonStyle(.borderedProminent).controlSize(.large)
                        .keyboardShortcut(.space, modifiers: [])
                    Button { tap(it, 10) } label: { Text("+10") }
                }

                GroupBox("Pass level for today (all sub-challenges)") {
                    VStack(alignment: .leading, spacing: 6) {
                        Picker("", selection: Binding(get: { store.level(on: key) }, set: { store.setLevel($0) })) {
                            ForEach(PassLevel.allCases) { Text($0.label).tag($0) }
                        }
                        .pickerStyle(.segmented).labelsHidden()
                        Text("Hard day? Choose 3 times or 1 time. Small and consistent beats big and broken.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(6)
                }
                .frame(maxWidth: 620)

                GroupBox("Benefit") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(t.virtue)
                        Text(t.source).font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                }
                .frame(maxWidth: 620)

                Text("All-time for this dhikr: \(store.total(for: it).formatted())")
                    .font(.callout).foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var dayBanner: some View {
        if store.dayStatus(on: Date()) == .pass {
            Label("Today's challenge is passed. Alhamdulillah, your streak is safe.", systemImage: "flag.checkered")
                .font(.headline).foregroundStyle(.green)
        } else if store.dayStatus(on: Date()) == .rest {
            Label("Rest day between challenges. Your streak is safe. Counting is optional.", systemImage: "moon.zzz.fill")
                .font(.headline).foregroundStyle(.blue)
        }
    }

    private func tap(_ it: Item, _ n: Int) {
        let before = store.count(it, on: key)
        let goal = max(1, store.goal(it, on: key))
        store.add(n, to: it)
        guard haptics else { return }
        let reached = before < goal && before + n >= goal
        NSHapticFeedbackManager.defaultPerformer.perform(reached ? .levelChange : .alignment, performanceTime: .default)
    }
}
