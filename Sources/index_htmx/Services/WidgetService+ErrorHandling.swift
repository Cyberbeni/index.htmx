import AsyncHTTPClient
import NIO

extension WidgetService {
	func handleErrorResponse(_ response: HTTPClientResponse) async throws {
		let body = try await response.body.collect(upTo: Config.maxResponseSize)
		Log.error("Error status code: \(response.status.code), body: \(String(buffer: body))")

		let sse = try await ByteBuffer.sse(event: id, html: ErrorView(title: "HTTP \(response.status.code)"))
		await publisher.publish(sse, id: id)
	}

	func handleErrorThrown(_ error: Error) async {
		Log.error("\(error)")
		do {
			let sse = try await ByteBuffer.sse(event: id, html: ErrorView(title: "Unexpected error (see logs)"))
			await publisher.publish(sse, id: id)
		} catch {
			Log.error("\(error)")
		}
	}
}
