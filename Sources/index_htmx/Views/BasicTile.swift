import Elementary

struct BasicTile: HTML {
	let config: Config.Cards.Card
	let samehostUrlPrefix: String
	let runTimestamp: String
	let isPwa: Bool
	let isMini: Bool

	var url: String {
		let url = isPwa ? (config.pwaUrl ?? config.url) : config.url
		return url.replaceSamehost(with: samehostUrlPrefix)
	}

	var aClass: String {
		isMini ? "tile mini" : "tile basic"
	}

	var content: some HTML {
		a(.href(url), .class(aClass), .role(.button)) {
			IconView(config.icon, runTimestamp: runTimestamp)
			div { config.title }
		}
	}
}
