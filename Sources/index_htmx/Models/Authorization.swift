enum Authorization {
	static func user(_ user: String, password: String) -> String {
		let authData = Data("\(user):\(password)".utf8).base64EncodedString()
		return "Basic \(authData)"
	}

	static func apiKey(_ apiKey: String) -> String {
		"Bearer \(apiKey)"
	}
}
