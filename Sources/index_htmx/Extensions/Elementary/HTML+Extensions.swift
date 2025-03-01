import Elementary
import NIO

extension HTML {
	consuming func render(into buffer: UnsafeMutablePointer<ByteBuffer>, chunkSize: Int = 1024) async throws {
		try await render(into: ByteBufferWriter(buffer: buffer), chunkSize: chunkSize)
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
