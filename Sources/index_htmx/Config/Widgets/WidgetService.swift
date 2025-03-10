protocol WidgetService: Sendable {
	associatedtype Config: WidgetConfig

	init(id: String, config: Config, publisher: Publisher)

	func start() async
}
