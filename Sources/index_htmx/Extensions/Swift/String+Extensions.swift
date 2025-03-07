import Hummingbird

extension String {
	func replaceSamehost(with newPrefix: String) -> String {
		let toReplace = "samehost"
		if hasPrefix(toReplace) {
			return newPrefix + String(dropFirst(toReplace.count))
		} else {
			return self
		}
	}

	func fileExtension() -> MediaType.FileExtension? {
		if let extPointIndex = lastIndex(of: ".") {
			let extIndex = index(after: extPointIndex)
			return .init(suffix(from: extIndex))
		}
		return nil
	}
}
