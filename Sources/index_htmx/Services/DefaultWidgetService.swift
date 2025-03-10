import AsyncHTTPClient
import Hummingbird
import NIOFoundationCompat

actor DefaultWidgetService<Config: WidgetConfig>: WidgetService {
	let id: String
	let config: Config
	let publisher: Publisher

	var runTask: Task<Void, Error>?

	init(id: String, config: Config, publisher: Publisher) {
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
				try await Task.sleep(for: .seconds(Config.pollingInterval))
			}
		}
	}

	func getData() async {
		do {
			let url = config.url.appending(config.path)
			var request = HTTPClientRequest(url: url)
			request.method = .GET
			request.headers = [
				"Accept": MediaType.applicationJson.description,
			]
			if let authHeader = config.authHeader() {
				request.headers.add(name: Config.authHeaderName, value: authHeader)
			}
			let response = try await HTTPClient.shared.execute(request, timeout: .seconds(Config.timeout))
			switch response.status.code {
			case 200:
				let body = try await response.body.collect(upTo: Config.maxResponseSize)
				if let response = try body.getJSONDecodable(
					Config.Response.self,
					decoder: Self.jsonDecoder(),
					at: 0,
					length: body.readableBytes
				) {
					Log.debug("HTTP call OK: \(response)")
					let sse = try await ByteBuffer.sse(event: id, html: config.render(response: response))
					await publisher.publish(sse, id: id)
				} else {
					Log.error("getJSONDecodable returned nil")
				}
			default:
				let body = try await response.body.collect(upTo: Config.maxResponseSize)
				Log.error("Error status code: \(response.status.code), body: \(String(buffer: body))")

				let sse = try await ByteBuffer.sse(event: id, html: ErrorView(title: "HTTP \(response.status.code)"))
				await publisher.publish(sse, id: id)
			}
		} catch {
			Log.error("\(error)")
			do {
				let sse = try await ByteBuffer.sse(event: id, html: ErrorView(title: "Unexpected error (see logs)"))
				await publisher.publish(sse, id: id)
			} catch {
				Log.error("\(error)")
			}
		}
	}
}
