import AsyncHTTPClient

struct AdGuard: WidgetConfig {
	let url: String
	let user: String
	let password: String

	var pollingInterval: Double { 5 }
}

actor AdGuardService: WidgetService {
	let id: String
	let config: AdGuard

	init(id: String, config: AdGuard) {
		self.id = id
		self.config = config
	}

	func getData() async {
		let url = config.url.appending("/control/stats")
		guard let authData = "\(config.user):\(config.password)"
			.data(using: .utf8)?
			.base64EncodedString()
		else {
			Log.error("Failed to create authData")
			return
		}
		do {
			var request = HTTPClientRequest(url: url)
			request.method = .GET
			request.headers = [
				"Authorization": "Bearer \(authData)",
			]
			let response = try await HTTPClient.shared.execute(request, timeout: .seconds(30))
			// TODO: parse response
			if (200 ..< 300).contains(response.status.code) {
				Log.debug("HTTP call OK.")
			} else {
				let body = try await response.body.collect(upTo: maxResponseSize)
				Log.error("Error status code: \(response.status.code), body: \(String(buffer: body))")
			}
		} catch {
			Log.error("\(error)")
		}
	}
}
