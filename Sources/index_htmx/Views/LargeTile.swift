import Elementary

struct LargeTile: HTML {
	let config: Config.Cards.Card
	let samehostUrlPrefix: String
	let runTimestamp: String
	let isPwa: Bool

	var url: String {
		let url = isPwa ? (config.pwaUrl ?? config.url) : config.url
		return url.replaceSamehost(with: samehostUrlPrefix)
	}

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
				config: config,
				samehostUrlPrefix: samehostUrlPrefix,
				runTimestamp: runTimestamp,
				isPwa: isPwa,
				isMini: false
			)
		}
	}
}
