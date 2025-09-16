import Elementary

struct Sonarr: WidgetConfig, ApiKeyAuth {
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let nextDays: Double?
	let previousDays: Double?
	let unmonitored: Bool?
	let apiKey: String
	let fields: [Field]?

	static let oneDay: TimeInterval = 86400

	var path: String {
		let start = Formatter.iso8601(date: Date(timeIntervalSinceNow: -(previousDays ?? 28) * Self.oneDay))
		let end = Formatter.iso8601(date: Date(timeIntervalSinceNow: (nextDays ?? 28) * Self.oneDay))
		return "/api/v3/calendar?includeSeries=true&start=\(start)&end=\(end)&unmonitored=\(unmonitored ?? true)"
	}

	static var defaultFields: [Field] { [.nextAiring, .previousAiring] }
	var pollingInterval: Int { 30 }

	enum Field: String, Decodable {
		case nextAiring
		case previousAiring

		var title: String {
			switch self {
			case .nextAiring: "Next airing"
			case .previousAiring: "Previous airing"
			}
		}

		func value(for _response: Response?) -> String {
			guard let _response else { return "-" }
			let now = Date()
			var response = _response
			response.sort(by: { $0.airDateUtc < $1.airDateUtc })
			switch self {
			case .nextAiring:
				if let episode = response.first(where: { $0.airDateUtc > now }) {
					let date = Formatter.nearby(date: episode.airDateUtc)
					if let title = episode.series.title {
						return "\(title): \(date)"
					} else {
						return "\(date)"
					}
				} else {
					return "-"
				}
			case .previousAiring:
				if let episode = response.last(where: { $0.airDateUtc < now }) {
					let date = Formatter.nearby(date: episode.airDateUtc)
					if let title = episode.series.title {
						return "\(title): \(date)"
					} else {
						return "\(date)"
					}
				} else {
					return "-"
				}
			}
		}
	}

	typealias Response = [Episode]

	struct Episode: Decodable {
		let airDateUtc: Date
		let series: Series

		struct Series: Decodable {
			let title: String?
		}
	}

	@HTMLBuilder
	func render(response: Response?) -> sending _HTMLArray<DetailItem> {
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: response))
		}
	}
}
