import AsyncAlgorithms
import Elementary
import Hummingbird
import ServiceLifecycle

extension Router {
	@discardableResult
	func addSseRoutes(runTimestamp: String, publisher: Publisher) -> Self {
		get("sse") { request, _ in
			Response(
				status: .ok,
				headers: [.contentType: "text/event-stream; charset=utf-8"],
				body: .init { writer in
					if request.uri.queryParameters["timestamp"].flatMap({ String($0) }) != runTimestamp {
						try await Task.sleep(for: .seconds(0.1))
						try await writer.writeSSE(event: "reload", html: HTMLRaw("location.reload()"))
						try await Task.sleep(for: .seconds(1))
					} else {
						// https://github.com/hummingbird-project/hummingbird-examples/blob/bcac6b501ab36f8df8e409d9893fb70921b64ae4/server-sent-events/Sources/App/Application%2Bbuild.swift#L67-L93
						let (stream, id) = publisher.subscribe()
						try await withGracefulShutdownHandler {
							// If connection if closed then this function will call the `onInboundCLosed` closure
							try await request.body.consumeWithInboundCloseHandler { _ in
								for try await value in stream {
									try await writer.write(value)
								}
							} onInboundClosed: {
								publisher.unsubscribe(id)
							}
						} onGracefulShutdown: {
							publisher.unsubscribe(id)
						}
					}
					try await writer.finish(nil)
				},
			)
		}

		return self
	}
}
