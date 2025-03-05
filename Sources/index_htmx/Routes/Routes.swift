import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addRoutes(
		runTimestamp: String,
		staticFilesTimestamp: String,
		generalConfig: Config.General
	) -> Self {
		get("") { request, _ in
			HTMLResponse {
				MainPage(
					generalConfig: generalConfig,
					localhostUrlPrefix: request.localhostUrlPrefix(fallback: generalConfig.baseUrlFallback),
					runTimestamp: runTimestamp,
					staticFilesTimestamp: staticFilesTimestamp,
					isPwa: false
				)
			}
		}

		get("pwa.html") { request, _ in
			HTMLResponse {
				MainPage(
					generalConfig: generalConfig,
					localhostUrlPrefix: request.localhostUrlPrefix(fallback: generalConfig.baseUrlFallback),
					runTimestamp: runTimestamp,
					staticFilesTimestamp: staticFilesTimestamp,
					isPwa: true
				)
			}
		}

		get("\(runTimestamp)/site.webmanifest") { _, _ in
			var icons = [[String: String]]()
			// TODO: add type to config
			for iconConfig in generalConfig.pwaIcons {
				icons.append([
					"src": "/\(runTimestamp)/\(iconConfig.value)",
					"type": "image/png",
					"sizes": iconConfig.key,
				])
			}
			let iconsText = try String(data: App.responseJsonEncoder().encode(icons), encoding: .utf8)
			return Response(
				status: .ok,
				headers: [
					.contentType: "application/manifest+json; charset=utf-8",
					.cacheControl: CacheControl.publicImmutable,
				],
				body: ResponseBody(byteBuffer: .init(string: """
				{
				"name": "\(generalConfig.title)",
				"display":"standalone",
				"start_url":"/pwa.html",
				"icons": \(iconsText ?? "[]")
				}
				"""))
			)
		}

		if generalConfig.showReloadConfigButton {
			post("reload_config") { _, _ in
				Task.detached {
					Entrypoint.reloadConfig()
				}
				return Response(status: .noContent)
			}
		}

		return self
	}
}
