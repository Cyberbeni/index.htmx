protocol WidgetConfig: Decodable, Sendable {}

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
