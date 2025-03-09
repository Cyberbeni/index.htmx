import Elementary

struct ErrorView: HTML {
	let title: String

	var content: some HTML {
		div(.class("error")) {
			title
		}
	}
}
