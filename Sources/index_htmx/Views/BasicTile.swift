import Elementary

struct BasicTile: HTML {
	let icon: String
	let title: String
	let url: String

	var content: some HTML {
		a(.href(url), .class("tile basic"), .role(.button)) {
			img(.src(icon))
			div { title }
		}
	}
}
