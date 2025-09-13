import Elementary

struct Section: HTML {
	let config: Config.Cards.Section
	let samehostUrlPrefix: String
	let runTimestamp: String
	let isExternal: Bool
	let isPwa: Bool

	var content: some HTML {
		div(.class("section")) {
			h6(.class("header")) {
				IconView(config.icon, runTimestamp: runTimestamp)
				div { config.title }
			}
			for card in config.cards {
				let url = card.resolvedUrl(samehostUrlPrefix: samehostUrlPrefix, isExternal: isExternal, isPwa: isPwa)
				LargeTile(
					url: url,
					config: card,
					runTimestamp: runTimestamp
				)
			}
		}
	}
}
