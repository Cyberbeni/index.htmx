import Elementary
import ElementaryHTMXSSE

struct MainPage: HTMLDocument {
	let generalConfig: Config.General
	let mainCardsConfig: Config.MainCards

	let samehostUrlPrefix: String
	let runTimestamp: String
	let staticFilesTimestamp: String
	let isPwa: Bool

	var title: String { generalConfig.title }

	var lang: String { "en" }

	var head: some HTML {
		meta(.charset(.utf8))
		meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"))
		meta(.name("mobile-web-app-capable"), .content("yes"))

		meta(.name("theme-color"), .content(generalConfig.theme.light), .media("(prefers-color-scheme: light)"))
		meta(.name("theme-color"), .content(generalConfig.theme.dark), .media("(prefers-color-scheme: dark)"))
		// TODO: figure out what works on iOS
		link(.href("/\(runTimestamp)/\(generalConfig.favicon)"), .rel(.icon))
		for (sizes, path) in generalConfig.pwaIcons {
			link(.href("/\(runTimestamp)/\(path)"), .rel("apple-touch-icon"), .sizes(sizes))
		}
		link(.href("/\(runTimestamp)/site.webmanifest"), .rel("manifest"))

		link(.href("/\(staticFilesTimestamp)/pico.css"), .rel(.stylesheet))
		link(.href("/\(staticFilesTimestamp)/style.css"), .rel(.stylesheet))
		for path in generalConfig.customCss {
			link(.href("/\(runTimestamp)/\(path)"), .rel(.stylesheet))
		}
		script(.src("/\(staticFilesTimestamp)/htmx.min.js")) {}
		script(.src("/\(staticFilesTimestamp)/htmxsse.min.js")) {}
		for path in generalConfig.customJs {
			script(.src("/\(runTimestamp)/\(path)"), .defer) {}
		}
	}

	var body: some HTML {
		main(.class("container"), .hx.ext(.sse), .sse.connect("/sse?timestamp=\(runTimestamp)")) {
			script(.sse.swap("reload")) {}
			div(.class("grid")) {
				for section in mainCardsConfig.sections {
					Section(
						config: section,
						samehostUrlPrefix: samehostUrlPrefix,
						runTimestamp: runTimestamp,
						isPwa: isPwa
					)
				}
				a(.href("/"), .style("display:block;--pico-text-decoration:none;")) {
					article(.style("display:flex;")) {
						img(.src("/\(runTimestamp)/placeholder.svg"), .width(48), .alt("logo"))
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
			a(.href(isPwa ? "/pwa.html" : "/"), .role(.button), .class("icon")) {
				svg {
					Elementary.title { "Refresh page" }
					use(.href("/\(staticFilesTimestamp)/refresh.svg#icon"), .width("100%"), .height("100%")) {}
				}
			}
			if generalConfig.showReloadConfigButton {
				button(.class("icon"), .on(.click, #"fetch("/reload_config",{method:"POST"})"#)) {
					svg {
						Elementary.title { "Reload config" }
						use(.href("/\(staticFilesTimestamp)/refresh.svg#icon"), .width("70%"), .height("70%"), .x("30%"), .y("30%")) {}
						use(.href("/\(staticFilesTimestamp)/settings.svg#icon"), .width("60%"), .height("60%")) {}
					}
				}
			}
		}
	}
}
