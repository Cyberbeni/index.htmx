import Elementary
import NIO

extension ByteBuffer {
	static func htmxSse(id: String, html innerHtml: consuming some HTML) async throws -> ByteBuffer {
		var buffer = ByteBuffer()
		buffer.reserveCapacity(512)
		buffer.writeStaticString("data: ")
		let html = hxPartial(.hx.target("#\(id)"), .hx.swap(.innerHTML)) {
			innerHtml
		}
		try await buffer.writeHtml(html)
		buffer.writeStaticString("\n\n")
		return buffer
	}
}
