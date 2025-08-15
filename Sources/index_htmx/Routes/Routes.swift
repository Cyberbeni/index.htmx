import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addRoutes(
		configDate: Date,
		runTimestamp: String,
		staticFilesTimestamp: String,
		generalConfig: Config.General,
		mainCardsConfig: Config.Cards,
		miniCardsConfig: Config.Cards
	) -> Self {
		@Sendable
		func mainPageResponse(request: consuming Request, isPwa: Bool) -> HTMLResponse {
			HTMLResponse(additionalHeaders: [
				.cacheControl: CacheControl.publicNoCache,
				.contentSecurityPolicy: "default-src 'self' 'unsafe-inline'",
			]) {
				MainPage(
					generalConfig: generalConfig,
					mainCardsConfig: mainCardsConfig,
					miniCardsConfig: miniCardsConfig,
					samehostUrlPrefix: request.samehostUrlPrefix(fallback: generalConfig.baseUrlFallback),
					runTimestamp: runTimestamp,
					staticFilesTimestamp: staticFilesTimestamp,
					isPwa: isPwa
				)
			}
		}

		get("") { request, context in
			try await request.ifModifiedSince(
				modificationDate: configDate,
				context: context
			) {
				mainPageResponse(request: request, isPwa: false)
			}
		}

		get("pwa.html") { request, context in
			try await request.ifModifiedSince(
				modificationDate: configDate,
				context: context
			) {
				mainPageResponse(request: request, isPwa: true)
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
		let webManifestData: ByteBuffer?
		do {
			webManifestData = try ByteBuffer(data: App.responseJsonEncoder().encode(webManifest))
		} catch {
			webManifestData = nil
			Log.error("Failed to encode webmanifest: \(error)")
		}
		get("\(runTimestamp)/site.webmanifest") { request, context in
			try await request.ifModifiedSince(
				modificationDate: configDate,
				context: context
			) {
				if let webManifestData {
					Response(
						status: .ok,
						headers: [
							.contentType: "application/manifest+json; charset=utf-8",
							.cacheControl: CacheControl.publicImmutable,
						],
						body: ResponseBody(byteBuffer: webManifestData)
					)
				} else {
					Response(
						status: .internalServerError
					)
				}
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
