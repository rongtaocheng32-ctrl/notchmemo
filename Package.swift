// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotchMemo",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "NotchMemo", targets: ["NotchMemo"])
    ],
    dependencies: [
        .package(url: "https://github.com/MrKai77/DynamicNotchKit.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "NotchMemo",
            dependencies: [
                .product(name: "DynamicNotchKit", package: "DynamicNotchKit")
            ]
        )
    ]
)
