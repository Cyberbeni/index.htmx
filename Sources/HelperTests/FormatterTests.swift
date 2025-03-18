@testable import index_htmx
import Testing

struct FormatterTests {
	static let thousandsSeparator = "\u{00a0}" // non-breaking space

	init() {
		// LANG is only read during the fist use of `.userLocale`
		// TODO: use mixed Locale for testing once this is solved: https://github.com/swiftlang/swift-foundation-icu/issues/49
		setenv("LANG", "hu", 1)
	}

	@Test(arguments: [
		(0.1234, "0,123"),
		(1.2345, "1,234"),
		(12.345, "12,34"),
		(123.45, "123,4"),
		(1234.5, "1234"),
		(12345.6, "12\(thousandsSeparator)346"),
		(123_456.7, "123\(thousandsSeparator)457"),
	])
	func decimalFormatting(input: Double, expectedOutput: String) {
		#expect(Formatter.number(input) == expectedOutput)
	}

	@Test(arguments: [
		(100, 100, "100%"),
		(1, 100, "1%"),
		(0.49, 100, "0%"),
		(0.51, 100, "1%"),
		(1, 1, "100%"),
		(0.1, 1, "10%"),
	])
	func percentageFormatting(input: Double, base: Double, expectedOutput: String) {
		#expect(Formatter.percentage(input, base: base) == expectedOutput)
	}

	@Test(arguments: [
		(1, "1 B/s"),
		(900, "900 B/s"),
		(1000, "1,0 kB/s"),
		(99 * 1024, "99,0 kB/s"),
		(110 * 1024, "110 kB/s"),
		(1000 * 1024, "1,0 MB/s"),
	])
	func transferSpeedFormatting(input: Int, expectedOutput: String) {
		#expect(Formatter.transferSpeed(input) == expectedOutput)
	}

	@Test(arguments: [
		(Date(timeIntervalSinceNow: 10), "ebben a percben"),
		(Date(timeIntervalSinceNow: 65), "1 perc múlva"),
		(Date(timeIntervalSinceNow: 60.4 * 60), "60 perc múlva"),
		(Date(timeIntervalSinceNow: -10), "ebben a percben"),
		(Date(timeIntervalSinceNow: -65), "1 perccel ezelőtt"),
	])
	func nearbyDateFormattingThisHour(input: Date, expectedOutput: String) {
		#expect(Formatter.nearby(date: input) == expectedOutput)
	}

	@Test(arguments: [
		(1, "tomorrow, "),
		(-1, "yesterday, "),
	])
	func nearbyDateFormattingWithinOneDay(input: Int, expectedOutput: String) throws {
		let date = try #require(Formatter.userCalendar.date(byAdding: .day, value: input, to: Date()))
		#expect(Formatter.nearby(date: date).hasPrefix(expectedOutput))
	}

	@Test
	func nearbyDateFormattingToday() throws {
		let date = try #require(Formatter.userCalendar.date(byAdding: .hour, value: 2, to: Date(), wrappingComponents: true))
		#expect(Formatter.nearby(date: date).hasPrefix("today, "))
	}

	@Test
	func nearbyDateFormattingThisWeek() throws {
		let now = Date()
		let dayOfWeek = Formatter.userCalendar.component(.weekday, from: now)
		if [1, 5, 6, 7].contains(dayOfWeek) {
			// Thursday-Sunday
			// Set to Tuesday
			let date = try #require(Formatter.userCalendar.date(bySetting: .weekday, value: 3, of: now))
			#expect(Formatter.nearby(date: date).hasPrefix("K "))
		} else {
			// Monday-Wednesday
			// Set to Friday
			let date = try #require(Formatter.userCalendar.date(bySetting: .weekday, value: 6, of: now))
			#expect(Formatter.nearby(date: date).hasPrefix("P "))
		}
	}

	@Test
	func nearbyDateFormattingSpecificDate() throws {
		let date = try #require(Formatter.userCalendar.date(from: .init(year: 2025, month: 1, day: 2, hour: 13, minute: 45)))
		#expect(Formatter.nearby(date: date) == "01. 02. 13:45")
	}
}
