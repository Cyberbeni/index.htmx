import Elementary

protocol WidgetConfig: Decodable, Sendable {
	associatedtype Response: Decodable
	associatedtype Field: Decodable
	associatedtype View: HTML

	var url: String { get }
	var fields: [Field]? { get }

	var path: String { get }
	static var authHeaderName: String { get }
	static var defaultFields: [Field] { get }
	static var pollingInterval: Int { get }
	static var timeout: Int64 { get }
	static var maxResponseSize: Int { get }

	@HTMLBuilder func render(response: Response?) -> View
	func authHeader() -> String?
}

extension WidgetConfig {
	var fieldConfig: [Field] { fields ?? Self.defaultFields }
	static var pollingInterval: Int { 5 }
	static var timeout: Int64 { 5 }
	static var maxResponseSize: Int { 1_000_000 }
}

// Password auth
protocol PasswordAuth {
	var user: String { get }
	var password: String { get }
}

extension WidgetConfig where Self: PasswordAuth {
	static var authHeaderName: String { "Authorization" }
	func authHeader() -> String? {
		guard !user.isEmpty, !password.isEmpty else { return nil }
		let authData = Data("\(user):\(password)".utf8).base64EncodedString()
		return "Basic \(authData)"
	}
}

// API key auth
protocol ApiKeyAuth {
	var apiKey: String { get }
}

extension WidgetConfig where Self: ApiKeyAuth {
	static var authHeaderName: String { "X-API-Key" }
	func authHeader() -> String? {
		guard !apiKey.isEmpty else { return nil }
		return apiKey
	}
}
