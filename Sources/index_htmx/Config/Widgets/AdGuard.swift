import AsyncHTTPClient
import Elementary
import NIOFoundationCompat

struct AdGuard: WidgetConfig {
	let url: String
	let user: String
	let password: String
	let fields: [Field]?

	static var defaultFields: [Field] { [.queries, .blocked, .latency] }
	var pollingInterval: Int64 { 5 }

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

		func value(for data: Data?) -> String {
			guard let data else { return "-" }
			// TODO: format numbers
			return switch self {
				case .queries: "\(data.numDnsQueries)"
				case .blocked: "\(data.numBlockedFiltering)"
				case .filtered: "\(data.numReplacedSafebrowsing + data.numReplacedSafesearch + data.numReplacedParental)"
				case .latency: "\(data.avgProcessingTime * 1000) ms"
			}
		}
	}

	struct Data: Decodable {
		var numDnsQueries: Int
		var numBlockedFiltering: Int
		var numReplacedSafebrowsing: Int
		var numReplacedSafesearch: Int
		var numReplacedParental: Int
		var avgProcessingTime: Double // microseconds
	}

	@HTMLBuilder
	func render(data: Data?) -> some HTML {
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: data))
		}
	}
}

actor AdGuardService: WidgetService {
	let id: String
	let config: AdGuard

	var runTask: Task<Void, Error>?

	init(id: String, config: AdGuard) {
		self.id = id
		self.config = config
	}

	deinit {
		runTask?.cancel()
		Log.debug("Service deinit: \(Self.self)")
	}

	func start() {
		guard runTask == nil else { return }
		runTask = Task { [weak self] in
			while !Task.isCancelled {
				await self?.getData()
				try await Task.sleep(for: .seconds(self?.config.pollingInterval ?? 1))
			}
		}
	}

	func getData() async {
		let url = config.url.appending("/control/stats")
		do {
			var request = HTTPClientRequest(url: url)
			request.method = .GET
			request.headers = [
				"Authorization": Authorization.user(config.user, password: config.password),
			]
			let response = try await HTTPClient.shared.execute(request, timeout: .seconds(config.pollingInterval - 1))
			// TODO: parse response
			if response.status.code == 200 {
				let body = try await response.body.collect(upTo: maxResponseSize)
				if let stats = try body.getJSONDecodable(Config.Data.self, decoder: jsonDecoder(), at: 0, length: body.readableBytes) {
					Log.debug("HTTP call OK: \(stats)")
					// TODO: render view
				} else {
					Log.error("getJSONDecodable returned nil")
				}
			} else {
				let body = try await response.body.collect(upTo: maxResponseSize)
				Log.error("Error status code: \(response.status.code), body: \(String(buffer: body))")
				// TODO: error
			}
		} catch {
			Log.error("\(error)")
			// TODO: error
		}
	}
}
