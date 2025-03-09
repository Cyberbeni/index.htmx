import Elementary

protocol WidgetConfig: Decodable, Sendable {
	associatedtype Data
	associatedtype View: HTML
	@HTMLBuilder func render(data: Data?) -> View
}

protocol WidgetService: Sendable {
	associatedtype Config: WidgetConfig
	init(id: String, config: Config)

	func start() async
	nonisolated func jsonDecoder() -> JSONDecoder
}

extension WidgetService {
	nonisolated func jsonDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}

	var maxResponseSize: Int { 1_000_000 }
}
