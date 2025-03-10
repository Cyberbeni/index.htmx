protocol WidgetService: Sendable {
	associatedtype Config: WidgetConfig
	static var maxResponseSize: Int { get }

	init(id: String, config: Config, publisher: Publisher)

	func start() async
}

extension WidgetService {
	static var maxResponseSize: Int { 1_000_000 }
}
