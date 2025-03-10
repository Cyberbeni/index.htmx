import Hummingbird

extension String {
	func fileExtension() -> MediaType.FileExtension? {
		if let extPointIndex = lastIndex(of: ".") {
			let extIndex = index(after: extPointIndex)
			return .init(suffix(from: extIndex))
		}
		return nil
	}
}
