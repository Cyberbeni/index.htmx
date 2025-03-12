import Elementary

struct Radarr: WidgetConfig, ApiKeyAuth {
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let nextDays: Double?
	let previousDays: Double?
	let unmonitored: Bool?
	let apiKey: String
	let fields: [Field]?

	static let oneDay: TimeInterval = 86400

	var startDate: Date { Date(timeIntervalSinceNow: -(previousDays ?? 28) * Self.oneDay) }
	var endDate: Date { Date(timeIntervalSinceNow: (nextDays ?? 90) * Self.oneDay) }
	var path: String {
		let start = Formatter.iso8601(date: startDate)
		let end = Formatter.iso8601(date: endDate)
		return "/api/v3/calendar?includeSeries=true&start=\(start)&end=\(end)&unmonitored=\(unmonitored ?? true)"
	}

	static var defaultFields: [Field] { [.nextRelease, .previousRelease] }
	var pollingInterval: Int { 30 }

	enum Field: String, Decodable {
		case nextRelease
		case previousRelease

		var title: String {
			switch self {
			case .nextRelease: "Next release"
			case .previousRelease: "Previous release"
			}
		}

		func value(for response: Response?, startDate: Date, endDate: Date) -> String {
			guard let response else { return "-" }
			let now = Date()
			var movies: [MovieSanitized] = response.compactMap { movie in
				if let title = movie.title,
				   let releaseDate = movie.releaseDate
				{
					.init(title: title, releaseDate: releaseDate)
				} else {
					nil
				}
			}
			// Calendar API could include movies based on different type of releases, which could result in releaseDate outside of our range
			movies.removeAll(where: { $0.releaseDate > startDate && $0.releaseDate < endDate })
			movies.sort(by: { $0.releaseDate < $1.releaseDate })
			switch self {
			case .nextRelease:
				if let movie = movies.first(where: { $0.releaseDate > now }) {
					let date = Formatter.nearby(date: movie.releaseDate)
					return "\(movie.title): \(date)"
				} else {
					return "-"
				}
			case .previousRelease:
				if let movie = movies.last(where: { $0.releaseDate < now }) {
					let date = Formatter.nearby(date: movie.releaseDate)
					return "\(movie.title): \(date)"
				} else {
					return "-"
				}
			}
		}
	}

	typealias Response = [Movie]

	struct Movie: Decodable {
		let title: String?
		/// Release date is based on the "Minimum Availability" setting for the movie in Radarr
		let releaseDate: Date?
	}

	struct MovieSanitized {
		let title: String
		let releaseDate: Date
	}

	@HTMLBuilder
	func render(response: Response?) -> some HTML {
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: response, startDate: startDate, endDate: endDate))
		}
	}
}
