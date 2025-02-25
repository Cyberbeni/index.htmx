import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addRoutes(timestamp: String) -> Self {
		get("") { request, _ in
			HTMLResponse {
				MainPage(localhostUrlPrefix: request.localhostUrlPrefix(fallback: "http://localhost:8080"), timestamp: timestamp)
			}
		}

		get("/site.webmanifest") { _, _ in
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

		return self
	}
}
