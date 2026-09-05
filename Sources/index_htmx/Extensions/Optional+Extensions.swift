extension Optional {
	func unwrap() throws -> Wrapped {
		guard case let .some(value) = self else {
			throw DecodingError.valueNotFound(
				Wrapped.self,
				DecodingError.Context(codingPath: [], debugDescription: "Optional doesn't contain value"),
			)
		}
		return value
	}
}
