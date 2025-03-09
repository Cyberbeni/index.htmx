@_exported import Foundation

@main
actor Entrypoint {
	private static var runTask: Task<Void, Error>?

	static func main() async throws {
		// TODO: setup sample configuration files
		while true {
			let app = try App()
			runTask = Task {
				try await app.run()
			}
			let result = await runTask?.result
			guard runTask?.isCancelled == true else {
				if case let .failure(error) = result {
					Log.error("app.run() returned error: \(error)")
				}
				return
			}
			Log.info("Restarting server")
		}
	}

	static func reloadConfig() {
		runTask?.cancel()
	}
}
