// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TaapTaapCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TaapTaapCore",
            targets: ["TaapTaapCore"]
        )
    ],
    targets: [
        .target(
            name: "TaapTaapCore"
        ),
        .testTarget(
            name: "TaapTaapCoreTests",
            dependencies: ["TaapTaapCore"]
        )
    ]
)
