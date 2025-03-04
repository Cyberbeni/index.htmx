import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addRoutes(runTimestamp: String, staticFilesTimestamp: String) -> Self {
		get("") { request, _ in
			HTMLResponse {
				MainPage(
					localhostUrlPrefix: request.localhostUrlPrefix(fallback: "http://localhost:8080"),
					runTimestamp: runTimestamp,
					staticFilesTimestamp: staticFilesTimestamp,
					isPwa: false
				)
			}
		}

		get("pwa.html") { request, _ in
			HTMLResponse {
				MainPage(
					localhostUrlPrefix: request.localhostUrlPrefix(fallback: "http://localhost:8080"),
					runTimestamp: runTimestamp,
					staticFilesTimestamp: staticFilesTimestamp,
					isPwa: true
				)
			}
		}

		get("\(runTimestamp)/site.webmanifest") { _, _ in
			Response(
				status: .ok,
				headers: [
					.contentType: "application/manifest+json; charset=utf-8",
					.cacheControl: CacheControl.publicImmutable,
				],
				// TODO: name, icon
				body: ResponseBody(byteBuffer: .init(string: """
				{
				"name": "Dashboard",
				"display":"standalone",
				"start_url":"/pwa.html",
				"icons": [
					{
					"src": "/\(staticFilesTimestamp)/apple-touch-icon.png",
					"type": "image/png",
					"sizes": "180x180"
					}
				]
				}
				"""))
			)
		}

		post("reload_config") { _, _ in
			Task.detached {
				Entrypoint.reloadConfig()
			}
			return Response(status: .noContent)
		}

		return self
	}
}
