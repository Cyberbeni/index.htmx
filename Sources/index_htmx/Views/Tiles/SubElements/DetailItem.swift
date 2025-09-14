import Elementary

struct DetailItem: HTML {
	let title: String
	let value: String

	var content: some HTML {
		div(.class("detail-item")) {
			div(.class("value")) { value }
			div(.class("title")) { title }
		}
	}
}
