import Elementary

struct Tdarr: WidgetConfig, ApiKeyAuth {
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let nodeName: String
	let apiKey: String?
	let fields: [Field]?

	var path: String { "/api/v2/get-nodes" }
	static var defaultFields: [Field] { [.workers, .transcodeQueue] }
	var pollingInterval: Int { 5 }

	enum Field: String, Decodable {
		case workers
		case transcodeQueue
		case healthCheckQueue

		var title: String {
			switch self {
			case .workers: "Workers"
			case .transcodeQueue: "Transcode"
			case .healthCheckQueue: "Health Check"
			}
		}

		func value(for response: Response?, nodeName: String) -> String {
			guard
				let response,
				let node = response.values.first(where: { node in
					node.nodeName == nodeName
				})
			else { return "-" }
			return switch self {
			case .workers: Formatter.number(node.workers.count)
			case .transcodeQueue: Formatter.number(node.queueLengths.transcodecpu + node.queueLengths.transcodegpu)
			case .healthCheckQueue: Formatter.number(node.queueLengths.healthcheckcpu + node.queueLengths.healthcheckgpu)
			}
		}
	}

	typealias Response = [String: InnerResponse]
	struct InnerResponse: Decodable {
		let nodeName: String
		let workers: [String: Worker]
		let queueLengths: QueueLengths

		struct Worker: Decodable {}

		struct QueueLengths: Decodable {
			let healthcheckcpu: Int
			let healthcheckgpu: Int
			let transcodecpu: Int
			let transcodegpu: Int
		}
	}

	@HTMLBuilder
	func render(response: Response?) -> some HTML & Sendable {
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: response, nodeName: nodeName))
		}
	}
}
