import Elementary
import ElementaryHTMXSSE

struct MainPage: HTMLDocument {
	let generalConfig: Config.General
	let mainCardsConfig: Config.Cards
	let miniCardsConfig: Config.Cards

	let context: RenderingContext

	var title: String { generalConfig.title }

	var lang: String { "en" }

	var head: some HTML {
		meta(.charset(.utf8))
		meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"))
		meta(.name("mobile-web-app-capable"), .content("yes"))
		base(.target("_blank"))

		meta(.name("theme-color"), .content(generalConfig.theme.light), .media("(prefers-color-scheme: light)"))
		meta(.name("theme-color"), .content(generalConfig.theme.dark), .media("(prefers-color-scheme: dark)"))
		link(.href("/\(context.runTimestamp)/\(generalConfig.favicon)"), .rel(.icon))
		for (sizes, path) in generalConfig.pwaIcons {
			link(.href("/\(context.runTimestamp)/\(path)"), .rel("apple-touch-icon"), .sizes(sizes))
		}
		link(.href("/\(context.runTimestamp)/site.webmanifest"), .rel("manifest"))

		link(.href("/\(context.staticFilesTimestamp)/pico.css"), .rel(.stylesheet))
		link(.href("/\(context.staticFilesTimestamp)/style.css"), .rel(.stylesheet))
		for path in generalConfig.customCss {
			link(.href("/\(context.runTimestamp)/\(path)"), .rel(.stylesheet))
		}
		script(.src("/\(context.staticFilesTimestamp)/htmx.min.js")) {}
		script(.src("/\(context.staticFilesTimestamp)/htmxsse.min.js")) {}
		for path in generalConfig.customJs {
			script(.src("/\(context.runTimestamp)/\(path)"), .defer) {}
		}
	}

	var body: some HTML {
		main(.class("container"), .hx.ext(.sse), .sse.connect("/sse?timestamp=\(context.runTimestamp)")) {
			script(.src("/\(context.staticFilesTimestamp)/autoreload.js")) {}
			script(.sse.swap("reload")) {}
			div(.class("grid")) {
				for section in mainCardsConfig.sections {
					Section(
						config: section,
						context: context
					)
				}
				for section in miniCardsConfig.sections {
					MiniSection(
						config: section,
						context: context
					)
				}
			}
		}
		footer(.class("container")) {
			a(.href(context.isPwa ? "/pwa.html" : "/"), .role(.button), .class("icon"), .title("Refresh page"), .target("_self")) {
				svg {
					use(.href("/\(context.staticFilesTimestamp)/refresh.svg#icon"), .width("100%"), .height("100%")) {}
				}
			}
			if generalConfig.showReloadConfigButton {
				button(.class("icon"), .on(.click, #"fetch("/reload_config",{method:"POST"})"#), .title("Reload config")) {
					svg {
						use(.href("/\(context.staticFilesTimestamp)/refresh.svg#icon"), .width("70%"), .height("70%"), .x("30%"), .y("30%")) {}
						use(.href("/\(context.staticFilesTimestamp)/settings.svg#icon"), .width("60%"), .height("60%")) {}
					}
				}
			}
		}
	}
}
