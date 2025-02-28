import Elementary
import ElementaryHTMXSSE

struct MainPage: HTMLDocument {
	let localhostUrlPrefix: String
	let runTimestamp: String
	let staticFilesTimestamp: String

	var title: String { "Hummingbird + Elementary + HTMX" }

	var head: some HTML {
		meta(.charset(.utf8))
		meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"))
		meta(.name("mobile-web-app-capable"), .content("yes"))

		// TODO: theme-color based on pico.css --pico-background-color or config
		meta(.name("theme-color"), .content("#fff"), HTMLAttribute(name: "media", value: "(prefers-color-scheme: light)"))
		meta(.name("theme-color"), .content("#13171f"), HTMLAttribute(name: "media", value: "(prefers-color-scheme: dark)"))
		// TODO: icons from config
		// TODO: figure out what works on iOS
		link(.href("/\(staticFilesTimestamp)/placeholder.svg"), .rel(.icon))
		link(.href("/\(staticFilesTimestamp)/apple-touch-icon.png"), .rel("apple-touch-icon"), HTMLAttribute(name: "sizes", value: "180x180"))
		link(.href("/\(runTimestamp)/site.webmanifest"), .rel("manifest"))

		// static files
		link(.href("/\(staticFilesTimestamp)/pico.css"), .rel(.stylesheet))
		link(.href("/\(staticFilesTimestamp)/style.css"), .rel(.stylesheet))
		script(.src("/\(staticFilesTimestamp)/htmx.min.js")) {}
		script(.src("/\(staticFilesTimestamp)/htmxsse.min.js")) {}
	}

	var body: some HTML {
		main(.class("container"), .hx.ext(.sse), .sse.connect("/sse?timestamp=\(runTimestamp)")) {
			// TODO: fallback?
			script(.src("/\(staticFilesTimestamp)/autoreload.js"), .sse.swap("reload")) {}
			// TODO: use flex
			// TODO: section header
			div(.class("grid")) {
				BasicTile(icon: "/\(staticFilesTimestamp)/placeholder.svg", title: "Home Assistant", url: "/")
				BasicTile(icon: "/\(staticFilesTimestamp)/placeholder.svg", title: "Home Assistant", url: "/")
				BasicTile(icon: "/\(staticFilesTimestamp)/placeholder.svg", title: "Home Assistant", url: "/")
				a(.href("/"), .style("display:block;--pico-text-decoration:none;")) {
					article(.style("display:flex;")) {
						img(.src("/\(staticFilesTimestamp)/placeholder.svg"), .width(48))
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
		footer(.class("container")) {
			a(.href("/"), .role(.button), .class("icon")) {
				svg {
					Elementary.title { "Refresh page" }
					use(.href("/\(staticFilesTimestamp)/refresh.svg#icon"), .width("100%"), .height("100%")) {}
				}
			}
			button(.class("icon"), .on(.click, #"fetch("/reload_config")"#)) {
				svg {
					Elementary.title { "Reload config" }
					use(.href("/\(staticFilesTimestamp)/refresh.svg#icon"), .width("70%"), .height("70%"), .x("30%"), .y("30%")) {}
					use(.href("/\(staticFilesTimestamp)/settings.svg#icon"), .width("60%"), .height("60%")) {}
				}
			}
		}
	}
}
