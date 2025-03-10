protocol WidgetService: Sendable {
	associatedtype Config: WidgetConfig

	init(id: String, config: Config, publisher: Publisher)

	func start() async
	static func jsonDecoder() -> JSONDecoder
	static func jsonEncoder() -> JSONEncoder
}

extension WidgetService {
	static func jsonDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}

	static func jsonEncoder() -> JSONEncoder {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}
}
