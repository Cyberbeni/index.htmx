#if canImport(SwiftGlibc)
	@preconcurrency import SwiftGlibc
#elseif canImport(SwiftMusl)
	import SwiftMusl
#else
	import Darwin
#endif

@main
enum Entrypoint {
	static func main() async throws {
		// Make sure print() output is instant
		setlinebuf(stdout)

		// TODO: setup sample configuration files
		let app = try App()
		try await app.run()
	}
}
