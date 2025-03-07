extension Config {
	struct MainCards: Codable {
		let sections: [Section]

		struct Section: Codable {
			let icon: Icon
			let title: String
			let cards: [Card]
		}

		struct Card: Codable {
			let icon: Icon
			let title: String
			let url: String
			let pwaUrl: String?
		}
	}
}
