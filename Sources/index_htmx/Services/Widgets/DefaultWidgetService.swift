import AsyncHTTPClient
import Hummingbird
import NIOFoundationEssentialsCompat
import ServiceLifecycle

actor DefaultWidgetService<Config: WidgetConfig>: WidgetService {
	let id: String
	var badgeId: String { "\(id)badge" }
	let config: Config
	let publisher: Publisher
	let titleBadgeService: TitleBadgeService

	init(
		id: String,
		config: Config,
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
				await self.getData()
				try? await Task.sleep(for: .seconds(self.config.pollingInterval))
			}
		}
	}

	func decode(body: ByteBuffer) throws -> Config.Response {
		if Config.Response.self == String.self {
			String(buffer: body) as! Config.Response
		} else {
			try Self.jsonDecoder().decode(Config.Response.self, from: body)
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
				let response = try decode(body: body)
				Log.debug("HTTP call OK: \(response)")
				let sse = try await ByteBuffer.sse(event: id, html: config.render(response: response))
				publisher.publish(sse, cacheId: id)
				if config.hasBadge {
					let content = config.renderBadge(response: response)
					titleBadgeService.updateBadge(id: id, content: content.text)
					let sse = try await ByteBuffer.sse(event: badgeId, html: content)
					publisher.publish(sse, cacheId: badgeId)
				} else {
					titleBadgeService.updateBadge(id: id, content: "")
				}
			default:
				try await handleErrorResponse(response)
			}
		} catch {
			await handleErrorThrown(error)
		}
	}
}
