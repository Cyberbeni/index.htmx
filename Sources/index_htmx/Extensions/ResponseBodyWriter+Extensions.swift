import Elementary
import Hummingbird

extension ResponseBodyWriter {
	mutating func writeSSE(event: String? = nil, html: (any HTML)?) async throws {
		var buffer = ByteBuffer()
		if let event {
			buffer.writeString("event: \(event)\n")
		}
		buffer.writeStaticString("data: ")
		if let html {
			// TODO: render into ByteBuffer
			try await buffer.writeString(html.renderAsync())
		}
		buffer.writeStaticString("\n\n")
		try await write(buffer)
	}
}
