import Elementary
import Hummingbird

extension ResponseBodyWriter {
	mutating func writeSSE(event: String? = nil, html: (any HTML)?) async throws {
		try await write(ByteBuffer.sse(event: event, html: html))
	}
}
