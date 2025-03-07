import Elementary

struct IconView: HTML {
	let icon: Icon
	let runTimestamp: String

	init(_ icon: Icon, runTimestamp: String) {
		self.icon = icon
		self.runTimestamp = runTimestamp
	}

	var content: some HTML {
		switch icon.type {
			case .mask:
				div(.class("mask icon"), .style("mask-image: url(/\(runTimestamp)/\(icon.path));")) {}
			case .doctoredSvg:
				svg(.class("icon")) {
					use(.href("/\(runTimestamp)/\(icon.path)#icon"), .width("100%"), .height("100%")) {}
				}
			case .image:
				img(.class("icon"), .src("/\(runTimestamp)/\(icon.path)"))
		}
	}
}
