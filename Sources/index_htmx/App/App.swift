import Hummingbird
import HummingbirdCompression

actor App {
	let configDir: URL
	let runTimestamp = "\(Date().timeIntervalSince1970)"
	let staticFilesTimestamp: String

	static func responseJsonEncoder() -> JSONEncoder {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}

	init() throws {
		#if DEBUG
			configDir = URL(filePath: "./debug_config")
			staticFilesTimestamp = runTimestamp
		#else
			configDir = URL(filePath: "/config")
			staticFilesTimestamp = try String(contentsOfFile: "/data/static_files_timestamp", encoding: .utf8)
		#endif
	}

	func run() async throws {
		// Parse config
		let decoder = Config.jsonDecoder()
		let generalConfig: Config.General
		do {
			generalConfig = try decoder.decode(
				Config.General.self,
				from: Data(contentsOf: configDir.appending(component: "config.general.json"))
			)
		} catch {
			Log.error("Error parsing config.general.json: \(error)")
			return
		}

		// Setup Application
		let router = Router()

		router
			.add(if: generalConfig.enableCompression, middleware: RequestDecompressionMiddleware())
			.addSseRoutes(runTimestamp: runTimestamp)
			.add(if: generalConfig.enableCompression, middleware: ResponseCompressionMiddleware())

		#if DEBUG
			router
				.add(middleware: FileMiddleware("./Resources/public", urlBasePath: "/" + staticFilesTimestamp, cacheControl: .init([
					(MediaType(type: .any), .publicImmutable),
				])))
				.add(middleware: FileMiddleware("./.debug_resources", urlBasePath: "/" + staticFilesTimestamp, cacheControl: .init([
					(MediaType(type: .any), .publicImmutable),
				])))
		#else
			router
				.add(middleware: FileMiddleware("/data/public", urlBasePath: "/" + staticFilesTimestamp, cacheControl: .init([
					(MediaType(type: .any), .publicImmutable),
				])))
		#endif

		router
			.add(middleware: FileMiddleware(
				configDir.appending(component: "public").path,
				urlBasePath: "/" + runTimestamp,
				cacheControl: .init([
					// TODO: add config to use noCache?
					(MediaType(type: .any), .publicImmutable),
				])
			))
			.addRoutes(
				runTimestamp: runTimestamp,
				staticFilesTimestamp: staticFilesTimestamp,
				generalConfig: generalConfig
			)

		let app = Application(
			router: router,
			configuration: ApplicationConfiguration(address: .hostname("0.0.0.0", port: 8080)),
			onServerRunning: { _ in
				Log.info("Server running")
			}
		)

		try await app.runService()
	}
}
