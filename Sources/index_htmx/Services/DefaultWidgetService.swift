import AsyncHTTPClient
import Hummingbird
import NIO
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

	static func jsonDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
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
				request.headers.add(name: "Authorization", value: authHeader)
			}
			let response = try await HTTPClient.shared.execute(request, timeout: .seconds(Config.timeout))
			switch response.status.code {
			case 200:
				let body = try await response.body.collect(upTo: Self.maxResponseSize)
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
				let body = try await response.body.collect(upTo: Self.maxResponseSize)
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
