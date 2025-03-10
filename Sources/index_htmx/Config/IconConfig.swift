extension Config {
	struct Icon: Codable {
		let type: IconType
		let path: String

		enum IconType: String, Codable {
			case mask
			case doctoredSvg = "doctored_svg"
			case image
		}

		enum CodingKeys: String, CodingKey {
			case type
			case path
		}

		init(from decoder: Decoder) throws {
			do {
				let container = try decoder.singleValueContainer()
				path = try container.decode(String.self)
				type = .image
			} catch {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				path = try container.decode(String.self, forKey: .path)
				type = try container.decode(IconType.self, forKey: .type)
			}
		}
	}
}
