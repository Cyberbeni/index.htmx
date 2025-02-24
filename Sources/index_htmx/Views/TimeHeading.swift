#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Elementary

struct TimeHeading: HTML {
    var content: some HTML<HTMLTag.h4> {
        h4 {
            "Server Time: \(Date())"
        }
    }
}
