import Elementary
import Hummingbird

extension ResponseBodyWriter {
	mutating func writeSSE(event: String? = nil, html: (any HTML)?) async throws {
		var buffer = ByteBuffer()
		if let event {
			buffer.writeString("event: \(event)\n")
		}
		buffer.writeStaticString("data: ")
		try await html?.render(into: &buffer)
		buffer.writeStaticString("\n\n")
		try await write(buffer)
	}
}
