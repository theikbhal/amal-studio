import SwiftUI
import AppKit

@main
struct AmalStudioApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var recorder = ScreenRecorder()
    @AppStorage("appearance") private var appearance = "system"

    init() {
        UserDefaults.standard.register(defaults: [
            "appearance": "system",
            "haptics": true,
            "reminderOn": false,
            "reminderMin": 20 * 60
        ])
    }

    private var scheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup("Amal Studio") {
            ContentView()
                .environmentObject(store)
                .environmentObject(recorder)
                .preferredColorScheme(scheme)
                .onAppear {
                    store.normalize()
                    Reminder.apply()
                }
        }
        .commands { CommandGroup(replacing: .newItem) {} }

        MenuBarExtra {
            MenuBarContent().environmentObject(recorder)
        } label: {
            Image(systemName: recorder.isRecording ? "record.circle.fill" : "record.circle")
        }
    }
}

struct MenuBarContent: View {
    @EnvironmentObject var recorder: ScreenRecorder

    var body: some View {
        Text(recorder.isRecording ? "Recording · \(recorder.elapsedText)" : "Not recording")
        Button("Stop recording") { recorder.stop() }.disabled(!recorder.isRecording)
        Divider()
        Button("Open Amal Studio") { NSApp.activate(ignoringOtherApps: true) }
        Button("Quit") { NSApplication.shared.terminate(nil) }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView().tabItem { Label("Today", systemImage: "checklist") }
            ChallengesView().tabItem { Label("Challenges", systemImage: "flag.checkered") }
            StreaksView().tabItem { Label("Streaks", systemImage: "flame.fill") }
            LibraryView().tabItem { Label("Library", systemImage: "books.vertical.fill") }
            RecordView().tabItem { Label("Record", systemImage: "record.circle") }
            HelpView().tabItem { Label("Help", systemImage: "questionmark.circle.fill") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .frame(minWidth: 980, minHeight: 740)
    }
}
