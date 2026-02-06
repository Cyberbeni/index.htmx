// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "index_htmx",
	platforms: [.macOS(.v26)],
	products: [
		.executable(
			name: "index_htmx",
			targets: ["index_htmx"],
		),
	],
	dependencies: [
		.package(url: "https://codeberg.org/Cyberbeni/CBLogging", from: "1.3.2"),
		.package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.11.0"),
		.package(url: "https://github.com/hummingbird-community/hummingbird-elementary", from: "0.4.1"),
		.package(url: "https://github.com/elementary-swift/elementary-htmx", from: "0.4.0"),
		.package(url: "https://github.com/swift-server/async-http-client", from: "1.25.2"),
		// Plugins:
		.package(url: "https://codeberg.org/Cyberbeni/SwiftFormat-mirror", from: "0.59.1"),
	],
	targets: [
		.executableTarget(
			name: "index_htmx",
			dependencies: [
				.product(name: "CBLogging", package: "CBLogging"),
				.product(name: "Hummingbird", package: "hummingbird"),
				.product(name: "HummingbirdElementary", package: "hummingbird-elementary"),
				.product(name: "ElementaryHTMX", package: "elementary-htmx"),
				.product(name: "ElementaryHTMXSSE", package: "elementary-htmx"),
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
			],
			swiftSettings: [
				.define("DEBUG", .when(configuration: .debug)),
				.unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
				.unsafeFlags(["-warnings-as-errors"], .when(configuration: .release)),
				// .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-s"], .when(configuration: .release)), // STRIP_STYLE = all
			],
		),
		.testTarget(
			name: "HelperTests",
			dependencies: ["index_htmx"],
		),
	],
)
