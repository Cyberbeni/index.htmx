import Elementary
import NIOCore
import ServiceLifecycle

actor TitleBadgeService: Service {
	private enum Command {
		case updateBadge(String, String)
	}

	private let generalConfig: Config.General
	private let publisher: Publisher

	private let eventName = "title"
	private var badges = [String: String]()
	private nonisolated let (commandStream, commandSource) = AsyncStream<Command>.makeStream()

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
			var titleText = generalConfig.title
			if count != 0 {
				titleText.append(" (\(count))")
			}
			let title = title { titleText }
			let sse = try await ByteBuffer.sse(event: eventName, html: title)
			publisher.publish(sse, cacheId: eventName)
		} catch {
			Log.error(error)
		}
	}
}
