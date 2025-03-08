protocol WidgetConfig: Codable {
	static var typeId: String { get }
	var id: String { get set }
}

protocol WidgetService {}
extension WidgetService {
	var maxResponseSize: Int { 1_000_000 }
}
