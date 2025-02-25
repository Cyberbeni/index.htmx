#if canImport(FoundationEssentials)
	import FoundationEssentials
#else
	import Foundation
#endif
import Elementary

struct TimeElement: HTML {
	var content: some HTML {
		p {
			"Server Time: \(Date())"
		}
	}
}
