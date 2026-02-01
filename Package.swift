// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudeCodeDashboard",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "ClaudeCodeDashboard",
            path: "ClaudeCodeDashboard",
            exclude: ["Info.plist"]
        )
    ]
)
