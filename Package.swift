// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AmalStudio",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "AmalStudio", path: "Sources/AmalStudio")
    ]
)
