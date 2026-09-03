import ServiceLifecycle

protocol WidgetService<Config>: Service, Sendable {
	associatedtype Config: WidgetConfig

	var id: String { get }
	var config: Config { get }
	var publisher: Publisher { get }

	init(id: String, config: Config, publisher: Publisher)

	static func jsonDecoder() -> JSONDecoder
}

extension WidgetService {
	static func jsonDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}
}
