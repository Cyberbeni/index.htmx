import Elementary
import NIOCore
import ServiceLifecycle

actor TitleBadgeService: Service {
	private enum Command {
		case updateBadge(String, String)
	}

	private let generalConfig: Config.General
	private let publisher: Publisher

	private var badges = [String: String]()
	private nonisolated let (commandStream, commandSource) = AsyncStream<Command>.makeStream()

	static let eventName = "title"

	private static let faviconCacheId = "favicon"
	static let originalFaviconEventName = "favicon-original"
	static let badgedFaviconEventName = "favicon-badged"

	init(
		generalConfig: Config.General,
		publisher: Publisher,
	) {
		self.generalConfig = generalConfig
		self.publisher = publisher
	}

	/// Service run function
	func run() async throws {
		try await withGracefulShutdownHandler {
			for try await command in self.commandStream {
				switch command {
				case let .updateBadge(id, content):
					await self._updateBadge(id: id, content: content)
				}
			}
		} onGracefulShutdown: {
			self.commandSource.finish()
		}
	}

	nonisolated func updateBadge(id: String, content: String) {
		commandSource.yield(.updateBadge(id, content))
	}

	private func _updateBadge(id: String, content: String) async {
		guard badges[id] != content else { return }
		do {
			badges[id] = content
			let count: Int = badges.values.reduce(0) { $0 + (Int($1) ?? 0) }

			// Update title
			var titleText = generalConfig.title
			if count != 0 {
				titleText.append(" (\(count))")
			}
			let title = title { titleText }
			let sse = try await ByteBuffer.sse(event: Self.eventName, html: title)
			publisher.publish(sse, cacheId: Self.eventName)

			// Update favicon
			if generalConfig.badgedFavicon != nil {
				let faviconSse: ByteBuffer
				if count == 0 {
					faviconSse = try await ByteBuffer.sse(event: Self.originalFaviconEventName, html: nil)
				} else {
					faviconSse = try await ByteBuffer.sse(event: Self.badgedFaviconEventName, html: nil)
				}
				publisher.publish(faviconSse, cacheId: Self.faviconCacheId)
			}
		} catch {
			Log.error(error)
		}
	}
}
