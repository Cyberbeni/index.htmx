// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "index_htmx",
	products: [
		.executable(
			name: "index_htmx",
			targets: ["index_htmx"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/vapor/vapor", from: "4.113.2"),
		.package(url: "https://github.com/vapor-community/vapor-elementary", from: "0.2.1"),
		.package(url: "https://github.com/sliemeobn/elementary-htmx", from: "0.4.0"),
		// Plugins:
		.package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.55.5"),
	],
	targets: [
		.executableTarget(
			name: "index_htmx",
			dependencies: [
				.product(name: "Vapor", package: "vapor"),
				.product(name: "VaporElementary", package: "vapor-elementary"),
				.product(name: "ElementaryHTMX", package: "elementary-htmx"),
				.product(name: "ElementaryHTMXSSE", package: "elementary-htmx"),
			],
			swiftSettings: [
				.unsafeFlags(["-warnings-as-errors"], .when(configuration: .release)),
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-s"], .when(configuration: .release)), // STRIP_STYLE = all
			]
		),
	]
)
