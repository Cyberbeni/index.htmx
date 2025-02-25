#if canImport(FoundationEssentials)
	import FoundationEssentials
#else
	import Foundation
#endif
import Hummingbird
import HummingbirdCompression

enum App {
	static func run() async throws {
		let router = Router()
		let timestamp = "\(Date().timeIntervalSince1970)"

		router
			.add(middleware: RequestDecompressionMiddleware())
			.addSseRoutes(timestamp: timestamp)
			.add(middleware: ResponseCompressionMiddleware())
			.add(middleware: FileMiddleware("/data/public", searchForIndexHtml: false))
			.addRoutes(timestamp: timestamp)

		let app = Application(
			router: router,
			configuration: ApplicationConfiguration(address: .hostname("0.0.0.0", port: 8080)),
			onServerRunning: { _ in
				print("Server running")
			}
		)

		try await app.runService()
	}
}
