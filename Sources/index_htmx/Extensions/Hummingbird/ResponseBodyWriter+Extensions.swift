import Elementary
import Hummingbird

extension ResponseBodyWriter {
	mutating func writeHtmxSse(id: String, html: some HTML) async throws {
		try await write(ByteBuffer.htmxSse(id: id, html: html))
	}
}
