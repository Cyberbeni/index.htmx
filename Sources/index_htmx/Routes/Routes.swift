import AsyncAlgorithms
import Elementary
import ElementaryHTMX
import Hummingbird
import HummingbirdElementary

enum Routes {
	static func addRoutes(to router: Router<some RequestContext>) {
		router.get("") { _, _ in
			HTMLResponse {
				MainPage()
			}
		}

		router.get("/site.webmanifest") { _, _ in
			Response(
				status: .ok,
				headers: [.contentType: "application/manifest+json"],
				// TODO: name, icon
				body: ResponseBody(byteBuffer: .init(string: """
				{
				"name": "Dashboard",
				"display":"standalone",
				"start_url":"/",
				"icons": [
					{
					"src": "icons/512.png",
					"type": "image/png",
					"sizes": "512x512"
					}
				]
				}
				"""))
			)
		}

		router.get("/time") { _, _ in
			Response(
				status: .ok,
				headers: [.contentType: "text/event-stream"],
				body: .init { writer in
					for await _ in AsyncTimerSequence.repeating(every: .seconds(1)).cancelOnGracefulShutdown() {
						try await writer.writeSSE(html: TimeElement())
					}
					try await writer.finish(nil)
				}
			)
		}
	}
}

extension ResponseBodyWriter {
    mutating func writeSSE(event: String? = nil, html: some HTML) async throws {
        if let event {
            try await write(ByteBuffer(string: "event: \(event)\n"))
        }
        try await write(ByteBuffer(string: "data: "))
        try await writeHTML(html)
        try await write(ByteBuffer(string: "\n\n"))
    }
}
