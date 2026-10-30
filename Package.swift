// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CutSwitch",
    platforms: [.macOS(.v13)],
    products: [.library(name: "CutSwitchCore", targets: ["CutSwitchCore"])],
    targets: [
        .target(name: "CutSwitchCore"),
        .testTarget(name: "CutSwitchCoreTests", dependencies: ["CutSwitchCore"]),
        .executableTarget(
            name: "CutSwitch",
            dependencies: ["CutSwitchCore"],
            path: "Sources/CutSwitch"
        )
    ]
)
