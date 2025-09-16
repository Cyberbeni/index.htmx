import Elementary

protocol WidgetConfig: Decodable, Sendable {
	associatedtype Service: WidgetService<Self>
	associatedtype Field: Decodable, Sendable
	associatedtype Response: Decodable, Sendable
	associatedtype View: HTML

	var url: String { get }
	var fields: [Field]? { get }

	var path: String { get }
	static var authHeaderName: String { get }
	static var defaultFields: [Field] { get }
	var pollingInterval: Int { get }
	static var timeout: Int64 { get }
	static var maxResponseSize: Int { get }

	// FIXME: make the return type of implementations `sending some View` after this is fixed: https://github.com/swiftlang/swift/issues/84318
	@HTMLBuilder func render(response: Response?) -> sending View
	func authHeader() -> String?
	func requestData() throws -> Data?
}

extension WidgetConfig {
	var fieldConfig: [Field] { fields ?? Self.defaultFields }
	var pollingInterval: Int { 5 }
	static var timeout: Int64 { 5 }
	static var maxResponseSize: Int { 1_000_000 }
	func requestData() throws -> Data? { nil }
}

/// MARK: Password auth
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

/// MARK: API key auth
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

/// MARK: Access token auth
protocol AccessTokenAuth {
	var accessToken: String { get }
}

extension WidgetConfig where Self: AccessTokenAuth {
	static var authHeaderName: String { "Authorization" }
	func authHeader() -> String? {
		guard !accessToken.isEmpty else { return nil }
		return "Bearer \(accessToken)"
	}
}
