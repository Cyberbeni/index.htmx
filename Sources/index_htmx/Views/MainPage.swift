import Elementary
import ElementaryHTMXSSE

struct MainPage: HTMLDocument {
    var title: String { "Hummingbird + Elementary + HTMX" }

    var head: some HTML {
        meta(.charset(.utf8))
		meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"))
		// TODO: icon
		// TODO: apple-touch-icon
		meta(.name("mobile-web-app-capable"), .content("yes"))
        script(.src("/htmx.min.js")) {}
        script(.src("/htmxsse.min.js")) {}
		link(.href("/pico.css"), .rel(.stylesheet))
		link(.href("/style.css"), .rel(.stylesheet))
    }

    var body: some HTML {
        header(.class("container")) {
            h2 { "Hummingbird + Elementary + HTMX Demo" }
        }
        main(.class("container")) {
			div(.class("grid")) {
				for _ in 0..<5 {
					div {
						h6 { "HTMX SSE example - main" }
						div(.hx.ext(.sse), .sse.connect("/time"), .sse.swap("message")) {
							TimeElement()
						}
					}
				}
			}
        }
    }
}
