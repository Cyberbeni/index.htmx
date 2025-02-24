import Elementary

struct BasicTile: HTML {
    var content: some HTML {
		a(.href("/"), .class("tile basic"), HTMLAttribute(name: "role", value: "button")) {
			img(.src("/placeholder.svg"))
			div { "Home Assistant" }
		}
    }
}
