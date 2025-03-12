// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "index_htmx",
	platforms: [.macOS(.v14)],
	products: [
		.executable(
			name: "index_htmx",
			targets: ["index_htmx"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/hummingbird-project/hummingbird", revision: "8219ec6cb484941c4195648b961cdb83a3d1290e"),
		.package(url: "https://github.com/hummingbird-community/hummingbird-elementary", from: "0.4.1"),
		.package(url: "https://github.com/sliemeobn/elementary-htmx", from: "0.4.0"),
		.package(url: "https://github.com/swift-server/async-http-client", from: "1.25.2"),
		// Plugins:
		.package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.55.5"),
	],
	targets: [
		.executableTarget(
			name: "index_htmx",
			dependencies: [
				.product(name: "Hummingbird", package: "hummingbird"),
				.product(name: "HummingbirdElementary", package: "hummingbird-elementary"),
				.product(name: "ElementaryHTMX", package: "elementary-htmx"),
				.product(name: "ElementaryHTMXSSE", package: "elementary-htmx"),
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
			],
			swiftSettings: [
				.define("DEBUG", .when(configuration: .debug)),
				.unsafeFlags(["-warnings-as-errors"], .when(configuration: .release)),
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-s"], .when(configuration: .release)), // STRIP_STYLE = all
			]
		),
		.testTarget(
			name: "HelperTests",
			dependencies: ["index_htmx"]
		),
	]
)
