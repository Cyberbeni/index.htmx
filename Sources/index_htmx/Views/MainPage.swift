import Elementary
import ElementaryHTMXSSE
import Foundation

struct MainPage: HTMLDocument {
	let localhostUrlPrefix: String
	let timestamp: String

	var title: String { "Hummingbird + Elementary + HTMX" }

	var head: some HTML {
		meta(.charset(.utf8))
		meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"))
		meta(.name("mobile-web-app-capable"), .content("yes"))

		// TODO: theme-color based on pico.css --pico-background-color or config
		meta(.name("theme-color"), .content("#fff"), HTMLAttribute(name: "media", value: "(prefers-color-scheme: light)"))
		meta(.name("theme-color"), .content("#13171f"), HTMLAttribute(name: "media", value: "(prefers-color-scheme: dark)"))
		// TODO: icons from config, svg is not supported
		link(.href("/placeholder.svg"), .rel(.icon))
		link(.href("/apple-touch-icon.png"), .rel("apple-touch-icon"), HTMLAttribute(name: "sizes", value: "180x180"))
		link(.href("/site.webmanifest"), .rel("manifest"))

		link(.href("/pico.css"), .rel(.stylesheet))
		link(.href("/style.css"), .rel(.stylesheet))
		script(.src("/htmx.min.js")) {}
		script(.src("/htmxsse.min.js")) {}
	}

	var body: some HTML {
		main(.class("container"), .hx.ext(.sse), .sse.connect("/sse?timestamp=\(timestamp)")) {
			script(.src("/autoreload.js"), .sse.swap("reload")) {}
			// TODO: use flex
			// TODO: section header
			div(.class("grid")) {
				BasicTile()
				BasicTile()
				BasicTile()
				DetailedTile()
				DetailedTile()
				DetailedTile()
				for _ in 0 ..< 5 {
					a(.href("/"), .style("display:block;--pico-text-decoration:none;")) {
						article(.style("display:flex;")) {
							img(.src("/placeholder.svg"), .width(48))
							div {
								h6 { "HTMX SSE example - main" }
								div(.sse.swap("message")) {
									TimeElement()
								}
							}
						}
					}
				}
			}
		}
		// TODO: footer reload button
	}
}
