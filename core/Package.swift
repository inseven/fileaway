// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileawayCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FileawayCore",
            targets: ["FileawayCore"]),
    ],
    dependencies: [
        .package(path: "./../dependencies/diligence"),
        .package(path: "./../dependencies/HashRainbow"),
        .package(path: "./../dependencies/interact"),
        .package(path: "./../dependencies/FilePicker"),
        .package(path: "./../dependencies/DIFlowLayout"),
        .package(url: "https://github.com/eonil/FSEvents.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FileawayCore",
            dependencies: [
                .product(name: "DIFlowLayout", package: "DIFlowLayout"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Diligence", package: "diligence"),
                .product(name: "HashRainbow", package: "hashrainbow"),
                .product(name: "Interact", package: "interact"),
                .product(name: "FilePicker", package: "FilePicker"),
                .product(name: "EonilFSEvents", package: "FSEvents", condition: .when(platforms: [.macOS])),
            ],
            resources: [
                .process("Licenses"),
            ]),
        .testTarget(
            name: "FileawayCoreTests",
            dependencies: ["FileawayCore"]),
    ]
)
