// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileawayCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FileawayCore",
            targets: ["FileawayCore"]),
    ],
    dependencies: [
        .package(path: "./../diligence"),
        .package(path: "./../interact"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FileawayCore",
            dependencies: [
                .product(name: "Diligence", package: "diligence"),
            ],
            resources: [
                .process("Licenses"),
            ]),
        .testTarget(
            name: "FileawayCoreTests",
            dependencies: ["FileawayCore"]),
    ]
)
