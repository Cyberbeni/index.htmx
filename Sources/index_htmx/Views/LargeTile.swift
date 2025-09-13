import Elementary

struct LargeTile: HTML {
	let url: String
	let config: Config.Cards.Card
	let runTimestamp: String

	var content: some HTML {
		if let widget = config.widget,
		   let widgetId = config.widgetId
		{
			a(.href(url), .class("tile detailed"), .role(.button)) {
				div(.class("title-row")) {
					IconView(config.icon, runTimestamp: runTimestamp)
					div { config.title }
				}
				div(.class("detail-row"), .sse.swap(widgetId)) {
					widget.placeholder()
				}
			}
		} else {
			BasicTile(
				url: url,
				config: config,
				runTimestamp: runTimestamp,
				isMini: false
			)
		}
	}
}
