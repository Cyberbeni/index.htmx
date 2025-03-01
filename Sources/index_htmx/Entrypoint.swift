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
			_ = await runTask?.result
			guard runTask?.isCancelled == true else {
				return
			}
			Log.info("Restarting server")
		}
	}

	static func reloadConfig() {
		runTask?.cancel()
	}
}
