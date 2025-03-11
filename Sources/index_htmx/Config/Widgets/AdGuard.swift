import Elementary

struct AdGuard: WidgetConfig, PasswordAuth {
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let user: String
	let password: String
	let fields: [Field]?

	var path: String { "/control/stats" }
	static var defaultFields: [Field] { [.queries, .blocked, .latency] }

	enum Field: String, Decodable {
		case queries
		case blocked
		case filtered
		case latency

		var title: String {
			switch self {
			case .queries: "Queries"
			case .blocked: "Blocked"
			case .filtered: "Filtered"
			case .latency: "Latency"
			}
		}

		func value(for response: Response?) -> String {
			guard let response else { return "-" }
			return switch self {
			case .queries: Formatter.number(response.numDnsQueries)
			case .blocked: Formatter.number(response.numBlockedFiltering)
			case .filtered: Formatter
				.number(response.numReplacedSafebrowsing + response.numReplacedSafesearch + response.numReplacedParental)
			case .latency: "\(Formatter.number(response.avgProcessingTime * 1000)) ms"
			}
		}
	}

	struct Response: Decodable {
		let numDnsQueries: Int
		let numBlockedFiltering: Int
		let numReplacedSafebrowsing: Int
		let numReplacedSafesearch: Int
		let numReplacedParental: Int
		let avgProcessingTime: Double // microseconds
	}

	@HTMLBuilder
	func render(response: Response?) -> some HTML {
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: response))
		}
	}
}
