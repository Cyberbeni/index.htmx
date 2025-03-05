import Hummingbird

extension Request {
	func localhostUrlPrefix(fallback: String) -> String {
		guard
			let scheme = head.scheme,
			let authority: String = head.authority,
			let host = authority.split(separator: ":").first
		else { return fallback }
		return "\(scheme)://\(host)"
	}
}
