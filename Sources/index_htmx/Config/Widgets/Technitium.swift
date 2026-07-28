import Elementary

// https://github.com/TechnitiumSoftware/DnsServer/blob/master/APIDOCS.md#get-stats
struct Technitium: WidgetConfig, AccessTokenAuth {
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let accessToken: String
	let fields: [Field]?

	var path: String {
		let start = Formatter.iso8601(date: Date(timeIntervalSinceNow: -Constants.oneDay))
		let end = Formatter.iso8601(date: Date(timeIntervalSinceNow: 60))
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
			case .blocked: Formatter.number(response.response.stats.totalBlocked)
			}
		}
	}

	struct Response: Decodable {
		struct InnerResponse: Decodable {
			struct Stats: Decodable {
				let totalQueries: Int
				let totalNoError: Int
				let totalServerFailure: Int
				let totalNxDomain: Int
				let totalRefused: Int
				let totalAuthoritative: Int
				let totalRecursive: Int
				let totalCached: Int
				let totalBlocked: Int
				let totalDropped: Int
				let totalClients: Int
				let zones: Int
				let cachedEntries: Int
				let allowedZones: Int
				let blockedZones: Int
				let allowListZones: Int
				let blockListZones: Int
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
