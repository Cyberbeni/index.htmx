import Elementary

struct ErrorView: HTML {
	let title: String

	var body: some HTML {
		div(.class("error")) {
			title
		}
	}
}
