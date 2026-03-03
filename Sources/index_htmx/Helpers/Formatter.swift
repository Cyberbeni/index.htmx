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

	static func percentage(_ value: Double, base: Double) -> String {
		FloatingPointFormatStyle.Percent(locale: userLocale)
			.precision(.fractionLength(0))
			.format(value / base)
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
		if abs(date.timeIntervalSinceNow) < 60.5 * 60 {
			Date.RelativeFormatStyle(allowedFields: [.minute], presentation: .named, locale: userLocale).format(date)
		} else if userCalendar.isDateInToday(date) ||
			userCalendar.isDateInTomorrow(date) ||
			userCalendar.isDateInYesterday(date)
		{
			"\(Date.RelativeFormatStyle(allowedFields: [.day], presentation: .named, locale: userLocale).format(date))\(dateTimeSeparator)\(shortTimeFormatter.string(from: date))"
		} else if abs(date.timeIntervalSinceNow) < 5 * 86400 ||
			userCalendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
		{
			thisWeekDateFormatter.string(from: date)
		} else {
			thisYearDateFormatter.string(from: date)
		}
	}
}

extension Formatter {
	static let userLocale: Locale = if let localeId = ProcessInfo.processInfo.environment["LANG"] {
		.init(identifier: localeId)
	} else {
		.current
	}

	static let userCalendar: Calendar = userLocale.calendar
}

private extension Formatter {
	static let dateTimeSeparator: String = if thisYearDateFormatter.dateFormat?.contains(",") == true {
		", "
	} else {
		" "
	}

	static let thisWeekDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = userLocale
		formatter.setLocalizedDateFormatFromTemplate("Ejjmm")
		if var dateFormat = formatter.dateFormat {
			let hour24Count = dateFormat.count(where: { $0 == "H" })
			let expectedHour24Count = shortTimeFormatter.dateFormat.count(where: { $0 == "H" })
			let hour12Count = dateFormat.count(where: { $0 == "h" })
			let expectedHour12Count = shortTimeFormatter.dateFormat.count(where: { $0 == "h" })
			if hour24Count != expectedHour24Count {
				dateFormat = dateFormat.replacingOccurrences(
					of: String(repeating: "H", count: hour24Count),
					with: String(repeating: "H", count: expectedHour24Count),
				)
			}
			if hour12Count != expectedHour12Count {
				dateFormat = dateFormat.replacingOccurrences(
					of: String(repeating: "h", count: hour12Count),
					with: String(repeating: "h", count: expectedHour12Count),
				)
			}
			formatter.dateFormat = dateFormat
		}
		// doesn't work on Linux at all
		// doesn't work on macOS with setLocalizedDateFormatFromTemplate()
		// formatter.doesRelativeDateFormatting = true
		return formatter
	}()

	static let thisYearDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = userLocale
		let monthCount = shortDateOnlyFormatter.dateFormat.count(where: { $0 == "M" })
		let dayCount = shortDateOnlyFormatter.dateFormat.count(where: { $0 == "d" })
		formatter.setLocalizedDateFormatFromTemplate(
			"\(String(repeating: "M", count: monthCount))\(String(repeating: "d", count: dayCount))jjmm",
		)
		return formatter
	}()

	static let shortDateOnlyFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = userLocale
		formatter.dateStyle = .short
		return formatter
	}()

	static let shortTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = userLocale
		formatter.timeStyle = .short
		return formatter
	}()
}
