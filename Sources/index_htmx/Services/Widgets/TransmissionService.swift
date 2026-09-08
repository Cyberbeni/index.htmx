import AsyncHTTPClient
import Hummingbird
import NIOFoundationEssentialsCompat
import ServiceLifecycle

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
		let titleBadgeService: TitleBadgeService

		let sessionHeaderName = "X-Transmission-Session-Id"
		var sessionToken: String?

		init(
			id: String,
			config: Transmission,
			publisher: Publisher,
			titleBadgeService: TitleBadgeService,
		) {
			self.id = id
			self.config = config
			self.publisher = publisher
			self.titleBadgeService = titleBadgeService
		}

		func run() async throws {
			await cancelWhenGracefulShutdown {
				while !Task.isCancelled {
					await self.getData(retryOnSessionRenew: true)
					try? await Task.sleep(for: .seconds(self.config.pollingInterval))
				}
			}
		}

		func jsonEncoder() -> JSONEncoder { JSONEncoder() }

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
				request.body = try .bytes(jsonEncoder().encode(Transmission.Request(
					method: "torrent-get",
					arguments: .init(fields: [
						"percentDone",
						"status",
						"rateDownload",
						"rateUpload",
					]),
				)))
				let response = try await HTTPClient.shared.execute(request, timeout: .seconds(Config.timeout))
				switch response.status.code {
				case 200:
					let body = try await response.body.collect(upTo: Config.maxResponseSize)
					let response = try Self.jsonDecoder().decode(Config.Response.self, from: body)
					Log.debug("HTTP call OK: \(response)")
					let sse = try await ByteBuffer.sse(event: id, html: config.render(response: response))
					publisher.publish(sse, cacheId: id)
					titleBadgeService.updateBadge(id: id, content: "")
				case 409:
					Log.debug("Session renew")
					if let sessionToken = response.headers.first(name: sessionHeaderName) {
						self.sessionToken = sessionToken
						if retryOnSessionRenew {
							await getData(retryOnSessionRenew: false)
						} else {
							let sse = try await ByteBuffer.sse(event: id, html: ErrorView(title: "Unexpected session renew"))
							publisher.publish(sse, cacheId: id)
						}
					} else {
						fallthrough
					}
				default:
					try await handleErrorResponse(response)
				}
			} catch {
				await handleErrorThrown(error)
			}
		}
	}
}
