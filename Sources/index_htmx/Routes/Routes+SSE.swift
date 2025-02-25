import AsyncAlgorithms
import Elementary
import ElementaryHTMX
import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addSseRoutes(timestamp: String) -> Self {
		get("/sse") { request, _ in
			Response(
				status: .ok,
				headers: [.contentType: "text/event-stream"],
				body: .init { writer in
					if request.uri.queryParameters["timestamp"].flatMap({ String($0) }) != timestamp {
						try await Task.sleep(for: .seconds(0.1))
						try await writer.writeSSE(event: "reload", html: nil)
						try await Task.sleep(for: .seconds(1))
					} else {
						for await _ in AsyncTimerSequence.repeating(every: .seconds(1)).cancelOnGracefulShutdown() {
							try await writer.writeSSE(html: TimeElement())
						}
					}
					try await writer.finish(nil)
				}
			)
		}

		return self
	}
}
