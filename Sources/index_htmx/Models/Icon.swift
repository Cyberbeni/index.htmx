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
				if let container = try? decoder.singleValueContainer() {
					self.path = try container.decode(String.self)
					self.type = .image
				} else {
					let container = try decoder.container(keyedBy: CodingKeys.self)
					self.path = try container.decode(String.self, forKey: .path)
					self.type = try container.decode(IconType.self, forKey: .type)
				}
			}
		}
