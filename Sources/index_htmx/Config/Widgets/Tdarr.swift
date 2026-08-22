import Elementary

struct Tdarr: WidgetConfig, ApiKeyAuth {
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let apiKey: String?
	let fields: [Field]?

	var path: String { "/api/v2/cruddb" }
	static var defaultFields: [Field] { [.transcodeQueue] }
	var pollingInterval: Int { 5 }

	enum Field: String, Decodable {
		case spaceSaved
		case transcodeQueue
		case transcodeSuccess
		case transcodeError
		case healthCheckQueue
		case healthCheckSuccess
		case healthCheckError

		var title: String {
			switch self {
			case .spaceSaved: "Space saved"
			case .transcodeQueue: "Transcode queue"
			case .transcodeSuccess: "Transcode success"
			case .transcodeError: "Transcode error"
			case .healthCheckQueue: "Health check queue"
			case .healthCheckSuccess: "Health check success"
			case .healthCheckError: "Health check error"
			}
		}

		func value(for response: Response?) -> String {
			guard let response else { return "-" }
			return switch self {
			case .spaceSaved: "\(Formatter.number(response.sizeDiff)) GB"
			case .transcodeQueue: Formatter.number(response.table1Count)
			case .transcodeSuccess: Formatter.number(response.table2Count)
			case .transcodeError: Formatter.number(response.table3Count)
			case .healthCheckQueue: Formatter.number(response.table4Count)
			case .healthCheckSuccess: Formatter.number(response.table5Count)
			case .healthCheckError: Formatter.number(response.table6Count)
			}
		}
	}

	struct Response: Decodable {
		let sizeDiff: Double // Space saved (GB)
		let table0Count: Int // Hold
		let table1Count: Int // Transcode Queue
		let table2Count: Int // Transcode: Success/Not Required
		let table3Count: Int // Transcode: Error/Cancelled
		let table4Count: Int // Health Check Queue
		let table5Count: Int // Health Check: Healthy
		let table6Count: Int // Health Check: Error/Cancelled
	}

	@HTMLBuilder
	func render(response: Response?) -> some HTML & Sendable {
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: response))
		}
	}

	struct Request: Encodable {
		let data: RequestData

		struct RequestData: Encodable {
			let collection: String
			let mode: String
			let docID: String
		}
	}

	func jsonEncoder() -> JSONEncoder { JSONEncoder() }

	func requestData() throws -> Data? {
		let request = Request(data: Request.RequestData(
			collection: "StatisticsJSONDB",
			mode: "getById",
			docID: "statistics",
		))
		return try jsonEncoder().encode(request)
	}
}
