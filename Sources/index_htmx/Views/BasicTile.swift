import Elementary

struct BasicTile: HTML {
	let config: Config.MainCards.Card
	let samehostUrlPrefix: String
	let runTimestamp: String
	let isPwa: Bool

	var url: String {
		let url = isPwa ? (config.pwaUrl ?? config.url) : config.url
		return url.replaceSamehost(with: samehostUrlPrefix)
	}

	var content: some HTML {
		a(.href(url), .class("tile basic"), .role(.button), .target("_blank")) {
			IconView(config.icon, runTimestamp: runTimestamp)
			div { config.title }
		}
	}
}
