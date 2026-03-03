import Elementary

struct BasicTile: HTML {
	let config: Config.Cards.Card
	let context: RenderingContext
	let isMini: Bool

	var aClass: String {
		isMini ? "tile mini" : "tile basic"
	}

	var body: some HTML {
		a(.href(config.resolvedUrl(context)), .class(aClass), .role(.button)) {
			IconView(config.icon, context: context)
			div { config.title }
		}
	}
}
