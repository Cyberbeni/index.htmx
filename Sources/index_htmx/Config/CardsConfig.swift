extension Config {
	struct Cards: Decodable {
		var sections: [Section]

		struct Section: Decodable {
			let icon: Icon
			let title: String
			var cards: [Card]
		}

		struct Card: Decodable {
			let icon: Icon
			let title: String
			let url: String
			let pwaUrl: String?
			let widget: Widget?

			/// Set up at runtime
			var widgetId: String?
		}
	}
}
