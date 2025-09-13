import Elementary

struct BasicTile: HTML {
	let url: String
	let config: Config.Cards.Card
	let runTimestamp: String
	let isMini: Bool

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
