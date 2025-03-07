import Elementary

struct Section: HTML {
	let runTimestamp: String

	// TODO: allow different styles of icons
	let icon: String
	let title: String

	// TODO: tile configs
	// let tileConfigs: []


	var content: some HTML {
		div(.class("section")) {
			h6(.class("header")) {
				div(.class("mask icon"), .style("mask-image: url(/\(runTimestamp)/\(icon));")) {}
				svg(.class("icon")) {
					use(.href("/\(runTimestamp)/refresh.svg#icon"), .width("100%"), .height("100%")) {}
				}
				div { title }
			}
			BasicTile(icon: "/\(runTimestamp)/placeholder.svg", title: "Home Assistant", url: "/")
			BasicTile(icon: "/\(runTimestamp)/placeholder.svg", title: "Home Assistant", url: "/")
		}
	}
}
