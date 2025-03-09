import AsyncHTTPClient
import NIOFoundationCompat

struct AdGuard: WidgetConfig {
	let url: String
	let user: String
	let password: String

	var pollingInterval: Int64 { 5 }
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

	private struct Stats: Decodable {
		var numDnsQueries: Int
		var numBlockedFiltering: Int
		var numReplacedSafebrowsing: Int
		var numReplacedSafesearch: Int
		var numReplacedParental: Int
		var avgProcessingTime: Double // microseconds
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
				if let stats = try body.getJSONDecodable(Stats.self, decoder: jsonDecoder(), at: 0, length: body.readableBytes) {
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
