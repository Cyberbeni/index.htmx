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
			let externalUrl: String?
			let pwaUrl: String?
			let widget: Widget?

			/// Set up at runtime
			var widgetId: String?

			func resolvedUrl(_ context: RenderingContext) -> String {
				let resolvedUrl: String
				if context.isPwa, let pwaUrl {
					resolvedUrl = pwaUrl
				} else if context.isExternal, let externalUrl {
					resolvedUrl = externalUrl
				} else {
					resolvedUrl = url
				}
				return resolvedUrl.replaceSamehost(with: context.samehostUrlPrefix)
			}
		}
	}
}
