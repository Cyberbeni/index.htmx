import AsyncHTTPClient
import Hummingbird
import NIOFoundationCompat

extension Transmission {
	struct Request: Encodable {
		let method: String
		let arguments: Arguments

		struct Arguments: Encodable {
			let fields: [String]
		}
	}

	actor Service: WidgetService {
		let id: String
		let config: Transmission
		let publisher: Publisher

		let sessionHeaderName = "X-Transmission-Session-Id"
		var sessionToken: String?
		var runTask: Task<Void, Error>?

		init(id: String, config: Transmission, publisher: Publisher) {
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
					await self?.getData(retryOnSessionRenew: true)
					try await Task.sleep(for: .seconds(self?.config.pollingInterval ?? 1))
				}
			}
		}

		func getData(retryOnSessionRenew: Bool) async {
			do {
				let url = config.url.appending(config.path)
				var request = HTTPClientRequest(url: url)
				request.method = .POST
				request.headers = [
					"Accept": MediaType.applicationJson.description,
					"Content-Type": MediaType.applicationJson.description,
				]
				if let authHeader = config.authHeader() {
					request.headers.add(name: Config.authHeaderName, value: authHeader)
				}
				if let sessionToken {
					request.headers.add(name: sessionHeaderName, value: sessionToken)
				}
				request.body = try .bytes(Self.jsonEncoder().encode(Transmission.Request(
					method: "torrent-get",
					arguments: .init(fields: [
						"percentDone",
						"status",
						"rateDownload",
						"rateUpload",
					])
				)))
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
				case 409:
					Log.debug("Session renew")
					if let sessionToken = response.headers.first(name: sessionHeaderName) {
						self.sessionToken = sessionToken
						if retryOnSessionRenew {
							await getData(retryOnSessionRenew: false)
						} else {
							let sse = try await ByteBuffer.sse(event: id, html: ErrorView(title: "Unexpected session renew"))
							await publisher.publish(sse, id: id)
						}
					} else {
						fallthrough
					}
				default:
					let body = try await response.body.collect(upTo: Config.maxResponseSize)
					let errorText = String(buffer: body)
					Log.error("Error status code: \(response.status.code), body: \(errorText)")

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
}
