import Elementary

struct LargeTile: HTML {
	let config: Config.Cards.Card
	let context: RenderingContext

	var body: some HTML {
		if let widget = config.widget,
		   let widgetId = config.widgetId
		{
			a(.href(config.resolvedUrl(context)), .class("tile"), .class(widget.hasDetails ? "detailed" : "basic"), .role(.button)) {
				if widget.hasDetails {
					div(.class("title-row")) {
						titleRow(widget: widget, widgetId: widgetId)
					}
					div(.class("detail-row"), .sse.swap(widgetId)) {
						widget.placeholder()
					}
				} else {
					titleRow(widget: widget, widgetId: widgetId)
				}
			}
		} else {
			BasicTile(
				config: config,
				context: context,
				isMini: false,
			)
		}
	}

	@HTMLBuilder
	func titleRow(widget: Config.Widget, widgetId: String) -> some HTML {
		IconView(config.icon, context: context)
		div { config.title }
		if widget.hasBadge {
			div(.class("badge"), .sse.swap(widgetId.appending("badge"))) { }
		}
	}
}
