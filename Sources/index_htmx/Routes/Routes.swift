import AsyncAlgorithms
import Elementary
import ElementaryHTMX
import Hummingbird
import HummingbirdElementary

extension App {
	static func addRoutes(to router: Router<some RequestContext>, timestamp: String) {
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
	}
}
