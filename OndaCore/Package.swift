// swift-tools-version:5.9
// OndaCore: gemeinsamer Kern für OndaTV (tvOS) und OndaMobile (iOS).
// Enthält nur plattformunabhängige Logik, damit beide Apps parallel darauf aufbauen.
import PackageDescription

let package = Package(
    name: "OndaCore",
    platforms: [.iOS(.v17), .tvOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "OndaCore", targets: ["OndaCore"])
    ],
    targets: [
        .target(name: "OndaCore"),
        .testTarget(name: "OndaCoreTests", dependencies: ["OndaCore"])
    ]
)
