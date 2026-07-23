// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Boarder",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Boarder",
            path: "Sources/Boarder"
        ),
        .testTarget(
            name: "BoarderTests",
            dependencies: ["Boarder"],
            path: "Tests/BoarderTests"
        )
    ]
)
