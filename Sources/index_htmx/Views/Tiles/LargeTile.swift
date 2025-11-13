import Elementary

struct LargeTile: HTML {
	let config: Config.Cards.Card
	let context: RenderingContext

	var content: some HTML {
		if let widget = config.widget,
		   let widgetId = config.widgetId
		{
			a(.href(config.resolvedUrl(context)), .class("tile detailed"), .role(.button)) {
				div(.class("title-row")) {
					IconView(config.icon, context: context)
					div { config.title }
				}
				div(.class("detail-row"), .id(widgetId)) {
					widget.placeholder()
				}
			}
		} else {
			BasicTile(
				config: config,
				context: context,
				isMini: false
			)
		}
	}
}
