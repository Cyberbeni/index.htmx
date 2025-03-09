import Elementary

protocol WidgetConfig: Decodable, Sendable {
	associatedtype Data: Decodable
	associatedtype Field: Decodable
	associatedtype View: HTML

	var fields: [Field]? { get }

	static var defaultFields: [Field] { get }

	@HTMLBuilder func render(data: Data?) -> View
}

extension WidgetConfig {
	var fieldConfig: [Field] { fields ?? Self.defaultFields }
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
