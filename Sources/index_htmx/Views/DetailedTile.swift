import Elementary

struct DetailedTile: HTML {
	var content: some HTML {
		a(.href("/"), .class("tile detailed"), HTMLAttribute(name: "role", value: "button")) {
			div(.class("title-row")) {
				img(.src("/placeholder.svg"))
				div { "AdGuard" }
			}
			div(.class("detail-row")) {
				div { "foo" }
				div { "foo" }
				div { "foo" }
				div { "foo" }
			}
		}
	}
}
