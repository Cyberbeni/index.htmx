import Elementary
import NIO

extension ByteBuffer {
	mutating func writeHTML(_ html: consuming any HTML, chunkSize: Int = 1024) async throws {
		try await html.render(into: ByteBufferWriter(buffer: &self), chunkSize: chunkSize)
	}
}

private class ByteBufferWriter: HTMLStreamWriter {
	private let buffer: UnsafeMutablePointer<ByteBuffer>

	init(buffer: UnsafeMutablePointer<ByteBuffer>) {
		self.buffer = buffer
	}

	func write(_ bytes: ArraySlice<UInt8>) async throws {
		buffer.pointee.writeBytes(bytes)
	}
}
