import Elementary

// https://github.com/TechnitiumSoftware/DnsServer/blob/master/APIDOCS.md#get-stats
struct Technitium: WidgetConfig, AccessTokenAuth {
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let accessToken: String
	let fields: [Field]?

	var path: String {
		let start = Formatter.iso8601(date: Date(timeIntervalSinceNow: -Constants.oneDay))
		let end = Formatter.iso8601(date: Date.now)
		return "/api/dashboard/stats/get?type=custom&start=\(start)&end=\(end)"
	}

	static var defaultFields: [Field] { [.queries, .blocked] }
	var pollingInterval: Int { 5 }

	enum Field: String, Decodable {
		case queries
		case blocked

		var title: String {
			switch self {
			case .queries: "Queries"
			case .blocked: "Blocked"
			}
		}

		func value(for response: Response?) -> String {
			guard let response else { return "-" }
			return switch self {
			case .queries: Formatter.number(response.response.stats.totalQueries)
			case .blocked: Formatter.number(response.response.stats.totalNxDomain + response.response.stats.totalBlocked)
			}
		}
	}

	struct Response: Decodable {
		struct InnerResponse: Decodable {
			struct Stats: Decodable {
				let totalQueries: Int
				let totalNxDomain: Int
				let totalBlocked: Int
			}

			let stats: Stats
		}

		let response: InnerResponse
	}

	@HTMLBuilder
	func render(response: Response?) -> some HTML & Sendable {
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: response))
		}
	}
}
