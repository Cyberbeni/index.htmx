import Elementary

struct Section: HTML {
	let config: Config.Cards.Section
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
				LargeTile(
					config: card,
					samehostUrlPrefix: samehostUrlPrefix,
					runTimestamp: runTimestamp,
					isPwa: isPwa
				)
			}
		}
	}
}
