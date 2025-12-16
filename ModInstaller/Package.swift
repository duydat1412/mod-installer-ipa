// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ModInstaller",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "ModInstaller",
            targets: ["ModInstaller"]),
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "ModInstaller",
            dependencies: ["ZIPFoundation"]),
    ]
)
