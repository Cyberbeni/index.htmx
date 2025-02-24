import Hummingbird

enum App {
    static func run() async throws {
        let router = Router(context: URLEncodedRequestContext.self)

        router.middlewares.add(FileMiddleware("/data/public", searchForIndexHtml: false))

        Routes.addRoutes(to: router)

        let app = Application(
            router: router,
			configuration: ApplicationConfiguration(address: .hostname("0.0.0.0", port: 8080)),
            onServerRunning: { _ in
                print("Server running")
            }
        )

        try await app.runService()
    }
}

struct URLEncodedRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage

    init(source: ApplicationRequestContextSource) {
        coreContext = .init(source: source)
    }

    var requestDecoder: URLEncodedFormDecoder { .init() }
}
