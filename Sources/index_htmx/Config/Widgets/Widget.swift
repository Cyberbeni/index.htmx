protocol WidgetConfig: Decodable {}

protocol WidgetService {}
extension WidgetService {
	var maxResponseSize: Int { 1_000_000 }
}
