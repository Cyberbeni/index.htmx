#if canImport(FoundationEssentials)
	import FoundationEssentials
#else
	import Foundation
#endif
import Hummingbird
import HummingbirdCompression

actor App {
	let runTimestamp = "\(Date().timeIntervalSince1970)"
	let staticFilesTimestamp: String

	init() throws {
		#if DEBUG
			staticFilesTimestamp = runTimestamp
		#else
			staticFilesTimestamp = try String(contentsOfFile: "/data/static_files_timestamp", encoding: .utf8)
		#endif
	}

	func run() async throws {
		let router = Router()

		router
			.add(middleware: RequestDecompressionMiddleware())
			.addSseRoutes(runTimestamp: runTimestamp)
			.add(middleware: ResponseCompressionMiddleware())

		#if DEBUG
			router
				.add(middleware: FileMiddleware("./Resources/public", urlBasePath: "/" + staticFilesTimestamp, cacheControl: .init([
					// TODO: use .any when it gets fixed
					(MediaType(type: .text), .publicImmutable),
					(MediaType(type: .image), .publicImmutable),
				])))
				.add(middleware: FileMiddleware("./.debug_resources", urlBasePath: "/" + staticFilesTimestamp, cacheControl: .init([
					// TODO: use .any when it gets fixed
					(MediaType(type: .text), .publicImmutable),
					(MediaType(type: .image), .publicImmutable),
				])))
		#else
			router
				.add(middleware: FileMiddleware("/data/public", urlBasePath: "/" + staticFilesTimestamp, cacheControl: .init([
					// TODO: use .any when it gets fixed
					(MediaType(type: .text), .publicImmutable),
					(MediaType(type: .image), .publicImmutable),
				])))
		#endif

		router
			.addRoutes(runTimestamp: runTimestamp, staticFilesTimestamp: staticFilesTimestamp)

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
