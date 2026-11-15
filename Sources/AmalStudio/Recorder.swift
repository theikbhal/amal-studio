import Foundation
import AppKit
import AVFoundation
import CoreMedia
import ScreenCaptureKit

enum RecError: LocalizedError {
    case noDisplay, encode, writer
    var errorDescription: String? {
        switch self {
        case .noDisplay: return "No display found."
        case .encode: return "Could not encode the image."
        case .writer: return "Could not create the video file."
        }
    }
}

/// Does the actual capture on a background queue (ScreenCaptureKit + AVAssetWriter, no audio in v1).
final class CaptureEngine: NSObject, SCStreamOutput, SCStreamDelegate {
    private var stream: SCStream?
    private var writer: AVAssetWriter?
    private var input: AVAssetWriterInput?
    private var sessionStarted = false
    private let queue = DispatchQueue(label: "amalstudio.capture")

    func start(filter: SCContentFilter, config: SCStreamConfiguration, url: URL, width: Int, height: Int) async throws {
        try? FileManager.default.removeItem(at: url)
        let w = try AVAssetWriter(outputURL: url, fileType: .mp4)
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: max(4_000_000, width * height * 4),
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
        let inp = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        inp.expectsMediaDataInRealTime = true
        guard w.canAdd(inp) else { throw RecError.writer }
        w.add(inp)
        queue.sync {
            writer = w
            input = inp
            sessionStarted = false
        }
        let s = SCStream(filter: filter, configuration: config, delegate: self)
        try s.addStreamOutput(self, type: .screen, sampleHandlerQueue: queue)
        stream = s
        try await s.startCapture()
    }

    func stop() async -> Bool {
        if let s = stream { try? await s.stopCapture() }
        stream = nil
        let state: (AVAssetWriter?, AVAssetWriterInput?, Bool) = queue.sync {
            let r = (writer, input, sessionStarted)
            writer = nil
            input = nil
            return r
        }
        guard let w = state.0, let inp = state.1 else { return false }
        if !state.2 {
            w.cancelWriting()
            return false
        }
        inp.markAsFinished()
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            w.finishWriting { c.resume() }
        }
        return w.status == .completed
    }

    // SCStreamOutput
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen, sampleBuffer.isValid, let writer = writer, let input = input else { return }
        guard let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let raw = attachments.first?[.status] as? Int,
              SCFrameStatus(rawValue: raw) == .complete else { return }
        if !sessionStarted {
            guard writer.startWriting() else { return }
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            sessionStarted = true
        }
        if writer.status == .writing, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        }
    }

    // SCStreamDelegate
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        NSLog("AmalStudio capture stopped: \(error.localizedDescription)")
    }
}

/// A red, click-through frame that shows exactly which part of the screen will be captured.
@MainActor
final class RegionOverlay {
    private var window: NSWindow?
    var windowNumber: Int { window?.windowNumber ?? 0 }

    /// rect: points, origin at the top-left of the main display.
    func show(rect: CGRect) {
        guard let screen = NSScreen.screens.first else { return }
        let frame = NSRect(x: screen.frame.minX + rect.minX,
                           y: screen.frame.maxY - rect.minY - rect.height,
                           width: rect.width, height: rect.height)
        if window == nil {
            let w = NSWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
            w.isOpaque = false
            w.backgroundColor = .clear
            w.hasShadow = false
            w.ignoresMouseEvents = true
            w.level = .statusBar
            w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            w.isReleasedWhenClosed = false
            let v = NSView(frame: NSRect(origin: .zero, size: frame.size))
            v.autoresizingMask = [.width, .height]
            v.wantsLayer = true
            v.layer?.borderColor = NSColor.systemRed.cgColor
            v.layer?.borderWidth = 3
            w.contentView = v
            window = w
        }
        window?.setFrame(frame, display: true)
        window?.orderFrontRegardless()
    }

    func hide() { window?.orderOut(nil) }
}

@MainActor
final class ScreenRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var countdown = 0
    @Published var elapsed: TimeInterval = 0
    @Published var message = ""
    @Published var lastFile: URL?
    @Published var overlayOn = false

    let overlay = RegionOverlay()
    private let engine = CaptureEngine()
    private var timer: Timer?
    private var startedAt = Date()
    private var currentURL: URL?

    static var outputDir: URL {
        FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AmalStudio", isDirectory: true)
    }

    var elapsedText: String {
        let s = Int(elapsed)
        return String(format: "%02d:%02d", s / 60, s % 60)
    }

    var hasPermission: Bool { CGPreflightScreenCaptureAccess() }

    func requestPermission() { _ = CGRequestScreenCaptureAccess() }

    func openPrivacySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: Video

    func start(preset: RecordPreset, region: CGRect, includeApp: Bool, delay: Int) {
        guard !isRecording, countdown == 0 else { return }
        message = ""
        Task {
            do {
                try await waitDelay(delay)
                let (filter, config) = try await makeFilter(preset: preset, region: region, includeApp: includeApp)
                let url = nextURL(preset: preset, ext: "mp4")
                try await engine.start(filter: filter, config: config, url: url, width: preset.width, height: preset.height)
                currentURL = url
                startedAt = Date()
                elapsed = 0
                isRecording = true
                message = "Recording… stop it here or from the menu bar icon."
                timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                    Task { @MainActor in
                        guard let self else { return }
                        self.elapsed = Date().timeIntervalSince(self.startedAt)
                    }
                }
            } catch {
                countdown = 0
                message = "Could not start: \(error.localizedDescription). Check the Screen Recording permission."
            }
        }
    }

    func stop() {
        guard isRecording else { return }
        isRecording = false
        timer?.invalidate()
        timer = nil
        let url = currentURL
        Task {
            let ok = await engine.stop()
            if ok, let url {
                lastFile = url
                message = "Saved: \(url.lastPathComponent)"
            } else {
                message = "Nothing was recorded. Check the Screen Recording permission, then quit and reopen the app."
            }
        }
    }

    // MARK: Image

    func screenshot(preset: RecordPreset, region: CGRect, includeApp: Bool, delay: Int) {
        guard !isRecording, countdown == 0 else { return }
        message = ""
        Task {
            do {
                try await waitDelay(delay)
                let (filter, config) = try await makeFilter(preset: preset, region: region, includeApp: includeApp)
                let url = nextURL(preset: preset, ext: "png")
                if #available(macOS 14.0, *) {
                    let img = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
                    let rep = NSBitmapImageRep(cgImage: img)
                    guard let png = rep.representation(using: .png, properties: [:]) else { throw RecError.encode }
                    try png.write(to: url)
                    lastFile = url
                    message = "Saved: \(url.lastPathComponent)"
                } else {
                    message = "Image capture needs macOS 14 or newer."
                }
            } catch {
                countdown = 0
                message = "Could not capture: \(error.localizedDescription). Check the Screen Recording permission."
            }
        }
    }

    // MARK: Helpers

    private func waitDelay(_ seconds: Int) async throws {
        guard seconds > 0 else { return }
        for s in stride(from: seconds, to: 0, by: -1) {
            countdown = s
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        countdown = 0
    }

    private func makeFilter(preset: RecordPreset, region: CGRect, includeApp: Bool) async throws -> (SCContentFilter, SCStreamConfiguration) {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = content.displays.first(where: { $0.displayID == CGMainDisplayID() }) ?? content.displays.first else {
            throw RecError.noDisplay
        }
        let filter: SCContentFilter
        if includeApp {
            let num = overlay.windowNumber
            let wins = content.windows.filter { num != 0 && $0.windowID == CGWindowID(num) }
            filter = SCContentFilter(display: display, excludingWindows: wins)
        } else {
            let me = Bundle.main.bundleIdentifier ?? ""
            let apps = content.applications.filter { $0.bundleIdentifier == me }
            filter = SCContentFilter(display: display, excludingApplications: apps, exceptingWindows: [])
        }
        let cfg = SCStreamConfiguration()
        cfg.width = preset.width
        cfg.height = preset.height
        cfg.sourceRect = region
        cfg.scalesToFit = true
        cfg.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(max(1, preset.fps)))
        cfg.pixelFormat = kCVPixelFormatType_32BGRA
        cfg.showsCursor = true
        cfg.queueDepth = 6
        return (filter, cfg)
    }

    private func nextURL(preset: RecordPreset, ext: String) -> URL {
        let dir = Self.outputDir
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd-HHmmss"
        return dir.appendingPathComponent("\(preset.id)-\(f.string(from: Date())).\(ext)")
    }
}
