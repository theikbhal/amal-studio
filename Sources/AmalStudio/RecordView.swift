import SwiftUI
import AppKit

struct RecordView: View {
    @EnvironmentObject var recorder: ScreenRecorder

    @AppStorage("presetID") private var presetID = "reel"
    @AppStorage("recZoom") private var zoom = 1.0
    @AppStorage("recX") private var px = 0.5
    @AppStorage("recY") private var py = 0.5
    @AppStorage("includeApp") private var includeApp = false
    @AppStorage("recDelay") private var delay = 3
    @AppStorage("customW") private var customW = 1080
    @AppStorage("customH") private var customH = 1080
    @AppStorage("customKind") private var customKind = "video"

    private var preset: RecordPreset {
        if presetID == "custom" {
            let w = max(16, customW - customW % 2)
            let h = max(16, customH - customH % 2)
            return RecordPreset(id: "custom", name: "Custom", platform: "Any screen", ratio: "\(w)x\(h)",
                                width: w, height: h, fps: customKind == "image" ? 1 : 30,
                                kind: customKind == "image" ? .image : .video, icon: "slider.horizontal.3")
        }
        return Presets.all.first { $0.id == presetID } ?? Presets.all[0]
    }

    /// Capture region in points, top-left origin, same aspect ratio as the preset.
    private var region: CGRect {
        let size = CGDisplayBounds(CGMainDisplayID()).size
        let aspect = CGFloat(preset.width) / CGFloat(preset.height)
        var w = size.width
        var h = size.width / aspect
        if h > size.height {
            h = size.height
            w = h * aspect
        }
        let z = CGFloat(zoom)
        w *= z
        h *= z
        return CGRect(x: ((size.width - w) * CGFloat(px)).rounded(),
                      y: ((size.height - h) * CGFloat(py)).rounded(),
                      width: w.rounded(), height: h.rounded())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Record").font(.largeTitle.bold())
                Text("Record any screen or app (a browser, a post, a tutorial) in the right size for each platform. Pick a preset, position the frame, then record.")
                    .font(.callout).foregroundStyle(.secondary)

                if !recorder.hasPermission { permissionBanner }

                presetGrid
                regionControls
                optionsRow
                actionRow
                statusArea
            }
            .padding(24)
        }
        .onChange(of: region) { _ in refreshOverlay() }
        .onChange(of: recorder.overlayOn) { _ in refreshOverlay() }
    }

    // MARK: Sections

    private var permissionBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Screen Recording permission is needed", systemImage: "exclamationmark.triangle.fill")
                .font(.headline).foregroundStyle(.orange)
            Text("Press Grant, allow Amal Studio in System Settings, Privacy and Security, Screen Recording, then quit and reopen the app.")
                .font(.callout)
            HStack {
                Button("Grant permission") { recorder.requestPermission() }
                Button("Open System Settings") { recorder.openPrivacySettings() }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.15)))
    }

    private var presetGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preset").font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 10)], spacing: 10) {
                ForEach(Presets.all) { p in presetCard(p) }
                customCard
            }
            if presetID == "custom" {
                HStack {
                    Stepper("Width \(customW)", value: $customW, in: 16...3840, step: 2)
                    Stepper("Height \(customH)", value: $customH, in: 16...3840, step: 2)
                    Picker("", selection: $customKind) {
                        Text("Video").tag("video")
                        Text("Image").tag("image")
                    }
                    .pickerStyle(.segmented).frame(width: 150).labelsHidden()
                }
            }
            Text("Suggested sizes. Platforms change their specs, so check the current guidelines before publishing.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private func presetCard(_ p: RecordPreset) -> some View {
        Button { presetID = p.id } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: p.icon)
                    Text(p.name).font(.headline).lineLimit(1)
                }
                Text("\(p.width) x \(p.height) · \(p.ratio) · \(p.kind == .video ? "video" : "image")")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(presetID == p.id ? Color.accentColor.opacity(0.22) : Color.secondary.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(presetID == p.id ? Color.accentColor : Color.clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private var customCard: some View {
        Button { presetID = "custom" } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Custom").font(.headline)
                }
                Text("Any size, any screen").font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(presetID == "custom" ? Color.accentColor.opacity(0.22) : Color.secondary.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(presetID == "custom" ? Color.accentColor : Color.clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private var regionControls: some View {
        GroupBox("Capture frame") {
            VStack(alignment: .leading, spacing: 8) {
                slider("Size", $zoom, 0.2...1.0)
                slider("Left to right", $px, 0...1)
                slider("Top to bottom", $py, 0...1)
                Toggle("Show the capture frame on screen (red border)", isOn: $recorder.overlayOn)
                let r = region
                Text("Frame: \(Int(r.width)) x \(Int(r.height)) pt at (\(Int(r.minX)), \(Int(r.minY))) → output \(preset.width) x \(preset.height) px")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(8)
        }
    }

    private func slider(_ title: String, _ value: Binding<Double>, _ range: ClosedRange<Double>) -> some View {
        HStack {
            Text(title).frame(width: 110, alignment: .leading)
            Slider(value: value, in: range)
        }
    }

    private var optionsRow: some View {
        HStack(spacing: 24) {
            Picker("Start delay", selection: $delay) {
                Text("None").tag(0)
                Text("3 s").tag(3)
                Text("5 s").tag(5)
                Text("10 s").tag(10)
            }
            .frame(width: 200)
            Toggle("Include Amal Studio's own windows", isOn: $includeApp)
            Spacer()
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            if preset.kind == .video {
                if recorder.isRecording {
                    Button { recorder.stop() } label: { Label("Stop recording", systemImage: "stop.circle.fill").frame(minWidth: 170) }
                        .buttonStyle(.borderedProminent).tint(.red).controlSize(.large)
                } else {
                    Button { recorder.start(preset: preset, region: region, includeApp: includeApp, delay: delay) } label: {
                        Label("Start recording", systemImage: "record.circle").frame(minWidth: 170)
                    }
                    .buttonStyle(.borderedProminent).controlSize(.large)
                    .disabled(recorder.countdown > 0)
                }
            } else {
                Button { recorder.screenshot(preset: preset, region: region, includeApp: includeApp, delay: delay) } label: {
                    Label("Take image", systemImage: "camera.fill").frame(minWidth: 170)
                }
                .buttonStyle(.borderedProminent).controlSize(.large)
                .disabled(recorder.countdown > 0)
            }
            if recorder.countdown > 0 {
                Text("Starting in \(recorder.countdown)…").font(.title3.bold()).foregroundStyle(.orange)
            }
            if recorder.isRecording {
                Text("● \(recorder.elapsedText)").font(.title3.bold().monospacedDigit()).foregroundStyle(.red)
            }
        }
    }

    private var statusArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !recorder.message.isEmpty { Text(recorder.message).font(.callout) }
            if let f = recorder.lastFile {
                HStack {
                    Image(systemName: f.pathExtension == "png" ? "photo" : "film")
                    Text(f.lastPathComponent).font(.callout)
                    Button("Reveal in Finder") { NSWorkspace.shared.activateFileViewerSelecting([f]) }
                    Button("Open") { NSWorkspace.shared.open(f) }
                }
            }
            Text("Files are saved in Movies/AmalStudio. v1 records video only (no audio). The menu bar icon can stop a recording while this window is hidden.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private func refreshOverlay() {
        if recorder.overlayOn { recorder.overlay.show(rect: region) } else { recorder.overlay.hide() }
    }
}
