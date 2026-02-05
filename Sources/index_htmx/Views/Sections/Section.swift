import Elementary

struct Section: HTML {
	let config: Config.Cards.Section
	let context: RenderingContext

	var body: some HTML {
		div(.class("section")) {
			h6(.class("header")) {
				IconView(config.icon, context: context)
				div { config.title }
			}
			for card in config.cards {
				LargeTile(
					config: card,
					context: context,
				)
			}
		}
	}
}
