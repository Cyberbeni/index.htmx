import Elementary
import NIO

extension ByteBuffer {
	static func sse(event: String?, html: consuming (any HTML & Sendable)?) async throws -> ByteBuffer {
		var buffer = ByteBuffer()
		buffer.reserveCapacity(512)
		if let event {
			buffer.writeString("event: \(event)\n")
		}
		buffer.writeStaticString("data: ")
		if let html {
			try await buffer.writeHTML(html)
		}
		buffer.writeStaticString("\n\n")
		return buffer
	}
}
