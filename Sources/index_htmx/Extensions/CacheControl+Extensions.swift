import Hummingbird

extension [CacheControl.Value] {
	static var publicImmutable: Self { [.public, .maxAge(31_536_000)] }
}

extension CacheControl {
	static var publicImmutable: String { [CacheControl.Value].publicImmutable.map(\.description).joined(separator: ", ") }
}
