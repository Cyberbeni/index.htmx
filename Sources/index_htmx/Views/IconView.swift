import Elementary

struct IconView: HTML {
	let icon: Config.Icon
	let runTimestamp: String

	init(_ icon: Config.Icon, runTimestamp: String) {
		self.icon = icon
		self.runTimestamp = runTimestamp
	}

	var content: some HTML {
		switch icon.type {
		case .mask:
			div(.class("mask icon"), .ariaHidden(true), .style("mask-image: url(/\(runTimestamp)/\(icon.path));")) {}
		case .doctoredSvg:
			svg(.class("icon"), .ariaHidden(true)) {
				use(.href("/\(runTimestamp)/\(icon.path)#icon"), .width("100%"), .height("100%")) {}
			}
		case .image:
			img(.class("icon"), .ariaHidden(true), .src("/\(runTimestamp)/\(icon.path)"))
		}
	}
}
