enum Formatter {
	static func string(from value: Int) -> String {
		IntegerFormatStyle(locale: userLocale).format(value)
	}

	static func string(from value: Double) -> String {
		if value < 1 {
			FloatingPointFormatStyle(locale: userLocale)
				.precision(.fractionLength(3))
				.format(value)
		} else if value < 10_000 {
			FloatingPointFormatStyle(locale: userLocale)
				.precision(.significantDigits(4))
				.format(value)
		} else {
			FloatingPointFormatStyle(locale: userLocale)
				.precision(.fractionLength(0))
				.format(value)
		}
	}
}

private extension Formatter {
	static let userLocale: Locale = {
		if let localeId = ProcessInfo.processInfo.environment["LANG"] {
			Locale(identifier: localeId)
		} else {
			Locale.current
		}
	}()
}
