// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Exino",
    platforms: [
        .macOS(.v11) // macOS 11.0+ for SwiftUI 3.0 features
    ],
    products: [
        .executable(name: "Exino", targets: ["Exino"])
    ],
    dependencies: [
        // Add any dependencies here
    ],
    targets: [
        .executableTarget(
            name: "Exino",
            dependencies: [],
            path: "Exino"
        ),
        .testTarget(
            name: "ExinoTests",
            dependencies: ["Exino"]
        )
    ]
)
