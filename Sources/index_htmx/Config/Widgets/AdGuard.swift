import AsyncHTTPClient
import Elementary
import NIO
import NIOFoundationCompat

struct AdGuard: WidgetConfig {
	let url: String
	let user: String
	let password: String
	let fields: [Field]?

	static var defaultFields: [Field] { [.queries, .blocked, .latency] }
	var pollingInterval: Int64 { 5 }
	var timeout: Int64 { 5 }

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
			return switch self {
			case .queries: Formatter.string(from: data.numDnsQueries)
			case .blocked: Formatter.string(from: data.numBlockedFiltering)
			case .filtered: Formatter.string(from: data.numReplacedSafebrowsing + data.numReplacedSafesearch + data.numReplacedParental)
			case .latency: "\(Formatter.string(from: data.avgProcessingTime * 1000)) ms"
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
	let publisher: Publisher

	var runTask: Task<Void, Error>?

	init(id: String, config: AdGuard, publisher: Publisher) {
		self.id = id
		self.config = config
		self.publisher = publisher
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
			let response = try await HTTPClient.shared.execute(request, timeout: .seconds(config.timeout))
			if response.status.code == 200 {
				let body = try await response.body.collect(upTo: maxResponseSize)
				if let data = try body.getJSONDecodable(Config.Data.self, decoder: jsonDecoder(), at: 0, length: body.readableBytes) {
					Log.debug("HTTP call OK: \(data)")
					let sse = try await ByteBuffer.sse(event: id, html: config.render(data: data))
					await publisher.publish(sse, id: id)
				} else {
					Log.error("getJSONDecodable returned nil")
				}
			} else {
				let body = try await response.body.collect(upTo: maxResponseSize)
				let errorText = String(buffer: body)
				Log.error("Error status code: \(response.status.code), body: \(errorText)")

				let sse = try await ByteBuffer.sse(event: id, html: ErrorView(title: "HTTP \(response.status.code) - \(errorText)"))
				await publisher.publish(sse, id: id)
			}
		} catch {
			Log.error("\(error)")
			do {
				let sse = try await ByteBuffer.sse(event: id, html: ErrorView(title: "\(error)"))
				await publisher.publish(sse, id: id)
			} catch {
				Log.error("\(error)")
			}
		}
	}
}
