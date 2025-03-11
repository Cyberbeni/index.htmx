enum Formatter {
	static func number(_ value: Int) -> String {
		IntegerFormatStyle(locale: userLocale).format(value)
	}

	static func number(_ value: Double) -> String {
		if value < 1 {
			FloatingPointFormatStyle(locale: userLocale)
				.precision(.fractionLength(3))
				.format(value)
		} else if value < 10000 {
			FloatingPointFormatStyle(locale: userLocale)
				.precision(.significantDigits(4))
				.format(value)
		} else {
			FloatingPointFormatStyle(locale: userLocale)
				.precision(.fractionLength(0))
				.format(value)
		}
	}

	/// value should be at least 0.95
	static func lowPrecisionNumber(_ value: Double) -> String {
		if value < 99.95 {
			FloatingPointFormatStyle(locale: userLocale)
				.precision(.fractionLength(1))
				.format(value)
		} else {
			FloatingPointFormatStyle(locale: userLocale)
				.precision(.fractionLength(0))
				.format(value)
		}
	}

	static func transferSpeed(_ bytesPerSec: Int) -> String {
		let cutoff = 0.95
		var speed = Double(bytesPerSec)
		if speed < cutoff * pow(1024, 1) {
			return "\(number(bytesPerSec)) B/s"
		} else if speed < cutoff * pow(1024, 2) {
			speed = speed / pow(1024, 1)
			return "\(lowPrecisionNumber(speed)) kB/s"
		} else if speed < cutoff * pow(1024, 3) {
			speed = speed / pow(1024, 2)
			return "\(lowPrecisionNumber(speed)) MB/s"
		} else if speed < cutoff * pow(1024, 4) {
			speed = speed / pow(1024, 3)
			return "\(lowPrecisionNumber(speed)) GB/s"
		} else {
			speed = speed / pow(1024, 4)
			return "\(lowPrecisionNumber(speed)) TB/s"
		}
	}

	static func iso8601(date: Date) -> String {
		Date.ISO8601FormatStyle().format(date)
	}

	static func nearby(date: Date) -> String {
		// TODO: format date, Date.RelativeFormatStyle or DateFormatter with doesRelativeDateFormatting
		"\(date)"
	}
}

private extension Formatter {
	static let userLocale: Locale = if let localeId = ProcessInfo.processInfo.environment["LANG"] {
		.init(identifier: localeId)
	} else {
		.current
	}
}
