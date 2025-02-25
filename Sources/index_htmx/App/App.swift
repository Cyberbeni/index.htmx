import Hummingbird
import HummingbirdCompression

enum App {
	static func run() async throws {
		let router = Router()

		// TODO: compression breaks event streams
		// router.middlewares.add(RequestDecompressionMiddleware())
		// router.middlewares.add(ResponseCompressionMiddleware())

		router.middlewares.add(FileMiddleware("/data/public", searchForIndexHtml: false))

		addRoutes(to: router)

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
