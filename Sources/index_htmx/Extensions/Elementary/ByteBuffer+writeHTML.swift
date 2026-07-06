import Elementary
import NIO

extension ByteBuffer {
	mutating func writeHTML(_ html: consuming any HTML & Sendable, chunkSize: Int = 1024) async throws {
		try await html.render(into: &self, chunkSize: chunkSize)
	}
}

private extension HTML where Self: Sendable {
	consuming func render(into buffer: UnsafeMutablePointer<ByteBuffer>, chunkSize: Int) async throws {
		try await render(into: ByteBufferWriter(buffer: buffer), chunkSize: chunkSize)
	}
}

private struct ByteBufferWriter: HTMLStreamWriter {
	private let buffer: UnsafeMutablePointer<ByteBuffer>

	init(buffer: UnsafeMutablePointer<ByteBuffer>) {
		self.buffer = buffer
	}

	func write(_ bytes: ArraySlice<UInt8>) async throws {
		buffer.pointee.writeBytes(bytes)
	}
}
