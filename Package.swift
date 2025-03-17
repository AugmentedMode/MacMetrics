// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MacMetrics",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "MacMetrics", targets: ["MacMetrics"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MacMetrics",
            dependencies: [],
            path: ".",
            exclude: ["README.md"]
        )
    ]
) 