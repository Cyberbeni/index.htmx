import Elementary

struct Tdarr: WidgetConfig, ApiKeyAuth {
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let apiKey: String?
	let fields: [Field]?

	var path: String { "/api/v2/stats/get-pies" }
	static var defaultFields: [Field] { [.transcodeQueue] }
	var pollingInterval: Int { 5 }

	enum Field: String, Decodable {
		case transcodeQueue
		case healthCheckQueue

		var title: String {
			switch self {
			case .transcodeQueue: "Transcode Queue"
			case .healthCheckQueue: "Health Check Queue"
			}
		}

		func value(for response: Response?) -> String {
			guard let response else { return "-" }
			return switch self {
			case .transcodeQueue: Formatter.number(response.pieStats.status.transcode.first(where: { $0.name == "Queued" })?.value ?? 0)
			case .healthCheckQueue: Formatter.number(response.pieStats.status.healthcheck.first(where: { $0.name == "Queued" })?.value ?? 0)
			}
		}
	}

	struct Response: Decodable {
		let pieStats: PieStats

		struct PieStats: Decodable {
			let status: Statuses

			struct Statuses: Decodable {
				let transcode: [Status]
				let healthcheck: [Status]

				struct Status: Decodable {
					let name: String
					let value: Int
				}
			}
		}
	}

	struct Request: Encodable {
		let data: RequestData

		struct RequestData: Encodable {
			let libraryId: String
		}
	}

	func requestData() throws -> Data? {
		let request = Request(data: .init(libraryId: ""))
		return try Service.jsonEncoder().encode(request)
	}

	@HTMLBuilder
	func render(response: Response?) -> some HTML & Sendable {
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: response))
		}
	}
}

extension Tdarr.Service {
	static func jsonEncoder() -> JSONEncoder { JSONEncoder() }
}
