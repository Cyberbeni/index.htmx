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
		func mainPageResponse(
			request: consuming Request,
			context: consuming Context,
			isPwa: Bool
		) async throws -> some ResponseGenerator {
			try await request.ifModifiedSince(
				modificationDate: configDate,
				context: context
			) {
				let isExternal: Bool
				if let externalHost = generalConfig.externalHost,
				   externalHost == request.head.authority
				{
					isExternal = true
				} else {
					isExternal = false
				}
				return HTMLResponse(additionalHeaders: [
					.cacheControl: CacheControl.publicNoCache,
					.contentSecurityPolicy: "default-src 'self' 'unsafe-inline'",
				]) {
					MainPage(
						generalConfig: generalConfig,
						mainCardsConfig: mainCardsConfig,
						miniCardsConfig: miniCardsConfig,
						context: RenderingContext(
							samehostUrlPrefix: request.samehostUrlPrefix(fallback: generalConfig.baseUrlFallback),
							runTimestamp: runTimestamp,
							staticFilesTimestamp: staticFilesTimestamp,
							isExternal: isExternal,
							isPwa: isPwa
						)
					)
				}
			}
		}

		get("") { request, context in
			try await mainPageResponse(request: request, context: context, isPwa: false)
		}

		get("pwa.html") { request, context in
			try await mainPageResponse(request: request, context: context, isPwa: true)
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
					await Entrypoint.reloadConfig()
				}
				return Response(status: .noContent)
			}
		}

		return self
	}
}
