protocol WidgetService<Config>: Sendable {
	associatedtype Config: WidgetConfig

	var id: String { get }
	var config: Config { get }
	var publisher: Publisher { get }

	init(id: String, config: Config, publisher: Publisher)

	func start() async
	static func jsonDecoder() -> JSONDecoder
	static func jsonEncoder() -> JSONEncoder
}

extension WidgetService {
	static func jsonDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}

	static func jsonEncoder() -> JSONEncoder {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}
}
