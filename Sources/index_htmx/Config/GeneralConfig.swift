extension Config {
	struct General: Decodable {
		let title: String
		let baseUrlFallback: String
		var enableCompression: Bool { _enableCompression ?? false }
		private let _enableCompression: Bool?
		var showReloadConfigButton: Bool { _showReloadConfigButton ?? false }
		private let _showReloadConfigButton: Bool?
		let favicon: String
		let pwaIcons: [String: String] // sizes: path
		var customCss: [String] { _customCss ?? [] }
		private let _customCss: [String]?
		var customJs: [String] { _customJs ?? [] }
		private let _customJs: [String]?
		var theme: Theme { _theme ?? .init(light: "#fff", dark: "#13171f") }
		private let _theme: Theme?

		enum CodingKeys: String, CodingKey {
			case title
			case baseUrlFallback
			case _enableCompression = "enableCompression"
			case _showReloadConfigButton = "showReloadConfigButton"
			case favicon
			case pwaIcons
			case _customCss = "customCss"
			case _customJs = "customJs"
			case _theme = "theme"
		}

		struct Theme: Decodable {
			let light: String
			let dark: String
		}
	}
}
