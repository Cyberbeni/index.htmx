#if canImport(FoundationEssentials)
	import FoundationEssentials
#else
	import Foundation
#endif
import AsyncAlgorithms
import Elementary
import ElementaryHTMX
import Hummingbird
import HummingbirdElementary

enum Routes {
	static func addRoutes(to router: Router<some RequestContext>) {
		let timestamp = "\(Date().timeIntervalSince1970)"

		router.get("") { request, _ in
			HTMLResponse {
				MainPage(localhostUrlPrefix: request.localhostUrlPrefix(fallback: "http://localhost:8080"), timestamp: timestamp)
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
					"src": "/apple-touch-icon.png",
					"type": "image/png",
					"sizes": "180x180"
					}
				]
				}
				"""))
			)
		}

		router.get("/time") { request, _ in
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
	}
}
