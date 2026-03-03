import Elementary

struct MiniSection: HTML {
	let config: Config.Cards.Section
	let context: RenderingContext

	var body: some HTML {
		div(.class("section mini")) {
			h6(.class("header")) {
				IconView(config.icon, context: context)
				div { config.title }
			}
			div(.class("grid mini")) {
				for card in config.cards {
					BasicTile(
						config: card,
						context: context,
						isMini: true,
					)
				}
			}
		}
	}
}
