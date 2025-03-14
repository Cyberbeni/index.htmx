import Hummingbird

extension [CacheControl.CacheControlValue] {
	static var publicImmutable: Self {
		#if DEBUG
			publicNoCache
		#else
			[.public, .maxAge(31_536_000), .immutable]
		#endif
	}

	static var publicNoCache: Self {
		[.public, .noCache]
	}
}

extension CacheControl {
	static var publicImmutable: String { [CacheControl.CacheControlValue].publicImmutable.map(\.description).joined(separator: ", ") }
	static var publicNoCache: String { [CacheControl.CacheControlValue].publicNoCache.map(\.description).joined(separator: ", ") }
}
