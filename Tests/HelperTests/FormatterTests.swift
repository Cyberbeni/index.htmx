@testable import index_htmx
import Testing

// Formatter uses en_001 Locale during tests

struct FormatterTests {
	@Test(arguments: [
		(0.1234, "0.123"),
		(1.2345, "1.234"),
		(12.345, "12.34"),
		(123.45, "123.4"),
		(1234.5, "1,234"),
		(12345.6, "12,346"),
	])
	func decimalFormatting(input: Double, expectedOutput: String) {
		print("LOCALE: \(Locale.current)")
		#expect(Formatter.string(from: input) == expectedOutput)
	}
}
