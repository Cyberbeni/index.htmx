import Elementary
import ElementaryHTMXSSE

struct MainPage: HTMLDocument {
    var title: String { "Hummingbird + Elementary + HTMX" }

    var head: some HTML {
        meta(.charset(.utf8))
        script(.src("/htmx.min.js")) {}
        script(.src("/htmxsse.min.js")) {}
    }

    var body: some HTML {
        header(.class("container")) {
            h2 { "Hummingbird + Elementary + HTMX Demo" }
            h6 { "HTMX SSE example - header" }
            div(.hx.ext(.sse), .sse.connect("/time"), .sse.swap("message")) {
                TimeHeading()
            }
        }
        main(.class("container")) {
            h6 { "HTMX SSE example - main" }
            div(.hx.ext(.sse), .sse.connect("/time"), .sse.swap("message")) {
                TimeHeading()
            }
        }
    }
}
