import Hummingbird
import ServiceLifecycle

actor App {
	let configDir: URL
	let configDate = Date()
	let runTimestamp: String
	let staticFilesTimestamp: String

	static func responseJsonEncoder() -> JSONEncoder {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}

	init() throws {
		let runTimestamp = "\(configDate.timeIntervalSince1970)"
		self.runTimestamp = runTimestamp
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
		var mainCardsConfig: Config.Cards
		let miniCardsConfig: Config.Cards

		do {
			generalConfig = try decoder.decode(
				Config.General.self,
				from: Data(contentsOf: configDir.appending(component: "config.general.json"))
			)
		} catch {
			Log.error("Error parsing config.general.json: \(error)")
			return
		}
		do {
			mainCardsConfig = try decoder.decode(
				Config.Cards.self,
				from: Data(contentsOf: configDir.appending(component: "config.main_cards.json"))
			)
		} catch {
			Log.warning("Error parsing config.main_cards.json: \(error)")
			mainCardsConfig = .init(sections: [])
		}
		do {
			miniCardsConfig = try decoder.decode(
				Config.Cards.self,
				from: Data(contentsOf: configDir.appending(component: "config.mini_cards.json"))
			)
		} catch {
			Log.warning("Error parsing config.mini_cards.json: \(error)")
			miniCardsConfig = .init(sections: [])
		}

		// Setup services
		let publisher = Publisher()
		var services: [any Service] = [publisher]
		var serviceIndex = 0
		for iSection in mainCardsConfig.sections.indices {
			for iCard in mainCardsConfig.sections[iSection].cards.indices {
				if let widget = mainCardsConfig.sections[iSection].cards[iCard].widget {
					let widgetId = "widget\(serviceIndex)"
					serviceIndex += 1
					mainCardsConfig.sections[iSection].cards[iCard].widgetId = widgetId
					if let service = widget.createService(id: widgetId, publisher: publisher) {
						services.append(service)
					}
				}
			}
		}

		// Setup Application
		let router = Router()

		router
			.addSseRoutes(runTimestamp: runTimestamp, publisher: publisher)

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
					(MediaType(type: .any), .publicImmutable),
				])
			))
			.addRoutes(
				configDate: configDate,
				runTimestamp: runTimestamp,
				staticFilesTimestamp: staticFilesTimestamp,
				generalConfig: generalConfig,
				mainCardsConfig: mainCardsConfig,
				miniCardsConfig: miniCardsConfig
			)

		let app = Application(
			router: router,
			configuration: ApplicationConfiguration(address: .hostname("0.0.0.0", port: 8080)),
			services: services,
			onServerRunning: { _ in
				Log.info("Server running")
			}
		)

		try await app.runService()
	}
}
