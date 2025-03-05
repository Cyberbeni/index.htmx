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

		let icons: [[String: String]] = generalConfig.pwaIcons.compactMap { iconConfig in
			let path = iconConfig.value
			let sizes = iconConfig.key
			if let fileExtension = path.fileExtension(),
			   let mediaType = MediaType.getMediaType(forExtension: fileExtension)
			{
				return [
					"src": "/\(runTimestamp)/\(path)",
					"type": mediaType.description,
					"sizes": sizes,
				]
			} else {
				return nil
			}
		}
		let webmanifest = Webmanifest(
			name: generalConfig.title,
			display: "standalone",
			startUrl: "/pwa.html",
			icons: icons
		)
		let webmanifestString: String?
		do {
			webmanifestString = try String(data: App.responseJsonEncoder().encode(webmanifest), encoding: .utf8)
		} catch {
			webmanifestString = nil
			Log.error("Failed to encode webmanifest: \(error)")
		}
		get("\(runTimestamp)/site.webmanifest") { _, _ in
			if let webmanifestString {
				Response(
					status: .ok,
					headers: [
						.contentType: "application/manifest+json; charset=utf-8",
						.cacheControl: CacheControl.publicImmutable,
					],
					body: ResponseBody(byteBuffer: .init(string: webmanifestString))
				)
			} else {
				Response(
					status: .internalServerError
				)
			}
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
