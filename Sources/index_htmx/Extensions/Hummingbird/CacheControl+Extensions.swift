import Hummingbird

extension [CacheControl.Value] {
	static var publicImmutable: Self {
		#if DEBUG
			[.public, .noCache]
		#else
			[.public, .maxAge(31_536_000)]
		#endif
	}

	static var publicNoCache: Self {
		[.public, .noCache]
	}
}

extension CacheControl {
	static var publicImmutable: String { [CacheControl.Value].publicImmutable.map(\.description).joined(separator: ", ") }
	static var publicNoCache: String { [CacheControl.Value].publicNoCache.map(\.description).joined(separator: ", ") }
}
