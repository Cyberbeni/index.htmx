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
				try await Task.sleep(for: .seconds(self?.config.pollingInterval ?? 1))
			}
		}
	}

	func decode(body: ByteBuffer) throws -> Config.Response? {
		if Config.Response.self == String.self {
			String(buffer: body) as? Config.Response
		} else {
			try body.getJSONDecodable(
				Config.Response.self,
				decoder: Self.jsonDecoder(),
				at: 0,
				length: body.readableBytes
			)
		}
	}

	func getData() async {
		do {
			let url = config.url.appending(config.path)
			var request = HTTPClientRequest(url: url)
			request.headers = [
				"Accept": (Config.Response.self == String.self) ? MediaType.textPlain.description : MediaType.applicationJson.description,
			]
			if let authHeader = config.authHeader() {
				request.headers.add(name: Config.authHeaderName, value: authHeader)
			}
			if let requestData = try config.requestData() {
				request.method = .POST
				request.body = .bytes(requestData)
				request.headers.add(name: "Content-Type", value: MediaType.applicationJson.description)
			} else {
				request.method = .GET
			}
			let response = try await HTTPClient.shared.execute(request, timeout: .seconds(Config.timeout))
			switch response.status.code {
			case 200:
				let body = try await response.body.collect(upTo: Config.maxResponseSize)
				if let response = try decode(body: body) {
					Log.debug("HTTP call OK: \(response)")
					let sse = try await ByteBuffer.sse(event: id, html: config.render(response: response))
					await publisher.publish(sse, id: id)
				} else {
					Log.error("Couldn't decode the response")
				}
			default:
				try await handleErrorResponse(response)
			}
		} catch {
			await handleErrorThrown(error)
		}
	}
}
