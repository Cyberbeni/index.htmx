import AsyncAlgorithms
import Hummingbird

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
						// TODO: stream the same event to  everyone
						// https://github.com/hummingbird-project/hummingbird-examples/blob/bcac6b501ab36f8df8e409d9893fb70921b64ae4/server-sent-events/Sources/App/Application%2Bbuild.swift#L67-L93
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
