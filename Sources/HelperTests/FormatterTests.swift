@testable import index_htmx
import Testing

struct FormatterTests {
	static let thousandsSeparator = "\u{00a0}" // non-breaking space

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
		setenv("LANG", "hu", 1)
		#expect(Formatter.number(input) == expectedOutput)
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
		setenv("LANG", "hu", 1)
		#expect(Formatter.transferSpeed(input) == expectedOutput)
	}
}
