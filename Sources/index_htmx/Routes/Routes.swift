import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addRoutes(
		runTimestamp: String,
		staticFilesTimestamp: String,
		generalConfig: Config.General,
		mainCardsConfig: Config.Cards,
		miniCardsConfig: Config.Cards
	) -> Self {
		get("") { request, _ in
			HTMLResponse {
				MainPage(
					generalConfig: generalConfig,
					mainCardsConfig: mainCardsConfig,
					miniCardsConfig: miniCardsConfig,
					samehostUrlPrefix: request.samehostUrlPrefix(fallback: generalConfig.baseUrlFallback),
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
					mainCardsConfig: mainCardsConfig,
					miniCardsConfig: miniCardsConfig,
					samehostUrlPrefix: request.samehostUrlPrefix(fallback: generalConfig.baseUrlFallback),
					runTimestamp: runTimestamp,
					staticFilesTimestamp: staticFilesTimestamp,
					isPwa: true
				)
			}
		}

		let icons = generalConfig.pwaIcons.compactMap { iconConfig in
			AppIcon(runTimestamp: runTimestamp, path: iconConfig.value, sizes: iconConfig.key)
		}
		let webManifest = WebManifest(
			name: generalConfig.title,
			display: "standalone",
			startUrl: "/pwa.html",
			icons: icons
		)
		let webManifestString: String?
		do {
			webManifestString = try String(data: App.responseJsonEncoder().encode(webManifest), encoding: .utf8)
		} catch {
			webManifestString = nil
			Log.error("Failed to encode webmanifest: \(error)")
		}
		get("\(runTimestamp)/site.webmanifest") { _, _ in
			if let webManifestString {
				Response(
					status: .ok,
					headers: [
						.contentType: "application/manifest+json; charset=utf-8",
						.cacheControl: CacheControl.publicImmutable,
					],
					body: ResponseBody(byteBuffer: .init(string: webManifestString))
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
