import Elementary

struct MiniSection: HTML {
	let config: Config.Cards.Section
	let samehostUrlPrefix: String
	let runTimestamp: String
	let isExternal: Bool
	let isPwa: Bool

	var content: some HTML {
		div(.class("section mini")) {
			h6(.class("header")) {
				IconView(config.icon, runTimestamp: runTimestamp)
				div { config.title }
			}
			div(.class("grid mini")) {
				for card in config.cards {
					let url = card.resolvedUrl(samehostUrlPrefix: samehostUrlPrefix, isExternal: isExternal, isPwa: isPwa)
					BasicTile(
						url: url,
						config: card,
						runTimestamp: runTimestamp,
						isMini: true
					)
				}
			}
		}
	}
}
