import AsyncHTTPClient
import NIO

extension WidgetService {
	func handleErrorResponse(_ response: HTTPClientResponse) async throws {
		let body = try await response.body.collect(upTo: Config.maxResponseSize)
		Log.error("Error status code: \(response.status.code), body: \(String(buffer: body))")

		let sse = try await ByteBuffer.htmxSse(id: id, html: ErrorView(title: "HTTP \(response.status.code)"))
		publisher.publish(sse, cacheId: id)
	}

	func handleErrorThrown(_ error: Error) async {
		Log.error(error)
		do {
			let sse = try await ByteBuffer.htmxSse(id: id, html: ErrorView(title: "Unexpected error (see logs)"))
			publisher.publish(sse, cacheId: id)
		} catch {
			Log.error(error)
		}
	}
}
