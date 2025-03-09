protocol WidgetConfig: Decodable, Sendable {}

protocol WidgetService {
	associatedtype Config: WidgetConfig
	init(id: String, config: Config)
}
extension WidgetService {
	var maxResponseSize: Int { 1_000_000 }
}
