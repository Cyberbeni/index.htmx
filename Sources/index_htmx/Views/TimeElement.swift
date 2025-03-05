import Elementary

struct TimeElement: HTML {
	var content: some HTML {
		p {
			"Server Time: \(Date())"
		}
	}
}
