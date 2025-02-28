#if canImport(SwiftGlibc)
	@preconcurrency import SwiftGlibc
#elseif canImport(SwiftMusl)
	import SwiftMusl
#else
	import Darwin
#endif

@main
actor Entrypoint {
	private static var runTask: Task<Void, Error>?

	static func main() async throws {
		// Make sure print() output is instant
		setlinebuf(stdout)

		// TODO: setup sample configuration files
		while (true) {
			let app = try App()
			runTask = Task {
				try await app.run()
			}
			_ = await runTask?.result
			guard runTask?.isCancelled == true else {
				return
			}
			print("Restarting server")
		}
	}

	static func reloadConfig() {
		runTask?.cancel()
	}
}
