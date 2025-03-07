import Elementary

struct Section: HTML {
	let config: Config.MainCards.Section
	let samehostUrlPrefix: String
	let runTimestamp: String
	let isPwa: Bool

	var content: some HTML {
		div(.class("section")) {
			h6(.class("header")) {
				IconView(config.icon, runTimestamp: runTimestamp)
				div { config.title }
			}
			for card in config.cards {
				BasicTile(config: card, samehostUrlPrefix: samehostUrlPrefix, runTimestamp: runTimestamp, isPwa: isPwa)
			}
		}
	}
}
