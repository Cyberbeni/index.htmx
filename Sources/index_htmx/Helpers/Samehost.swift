import Hummingbird

extension Request {
	func samehostUrlPrefix(fallback: String) -> String {
		guard
			let scheme = head.scheme,
			let authority: String = head.authority,
			let host = authority.split(separator: ":").first
		else { return fallback }
		return "\(scheme)://\(host)"
	}
}

extension String {
	func replaceSamehost(with newPrefix: String) -> String {
		let toReplace = "samehost"
		if hasPrefix(toReplace) {
			return newPrefix + String(dropFirst(toReplace.count))
		} else {
			return self
		}
	}
}
