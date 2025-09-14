import Elementary

struct IconView: HTML {
	let icon: Config.Icon
	let context: RenderingContext

	init(_ icon: Config.Icon, context: RenderingContext) {
		self.icon = icon
		self.context = context
	}

	var content: some HTML {
		switch icon.type {
		case .mask:
			div(.class("mask icon"), .ariaHidden(true), .style("mask-image: url(/\(context.runTimestamp)/\(icon.path));")) {}
		case .doctoredSvg:
			svg(.class("icon"), .ariaHidden(true)) {
				use(.href("/\(context.runTimestamp)/\(icon.path)#icon"), .width("100%"), .height("100%")) {}
			}
		case .image:
			img(.class("icon"), .ariaHidden(true), .src("/\(context.runTimestamp)/\(icon.path)"))
		}
	}
}
