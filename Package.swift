// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LectionaryScraper",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DionysiusParochieReadings",
            targets: ["DionysiusParochieReadings"]),
		.library(
			name: "Evangelizo",
			targets: ["Evangelizo"]),
		.library(
			name: "UsccbReadings",
			targets: ["UsccbReadings"]),
		.executable(name: "DionysiusDownloader", targets: ["DionysiusDownloader"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/dev1an/Kanna.git", .branch("feature/native-libxml2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LectionaryScraper",
            dependencies: ["Kanna"]),
        .target(
            name: "DionysiusParochieReadings",
            dependencies: ["LectionaryScraper"]),
        .target(
            name: "Evangelizo",
            dependencies: ["LectionaryScraper"]),
        .target(
            name: "UsccbReadings",
            dependencies: ["LectionaryScraper"]),

        .target(
            name: "DionysiusDownloader",
            dependencies: ["DionysiusParochieReadings"]),
		.testTarget(
            name: "DionysiusTests",
            dependencies: ["DionysiusParochieReadings"]),
		.testTarget(
			name: "EvangelizoTests",
			dependencies: ["Evangelizo"]),
		.testTarget(
			name: "UsccbTests",
			dependencies: ["UsccbReadings"]),
    ]
)
