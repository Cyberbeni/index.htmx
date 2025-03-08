// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension Config {
	enum Widget: Decodable {
		case adGuard(AdGuard)

		enum CodingKeys: String, CodingKey {
			case type
		}

		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			let type = try container.decode(String.self, forKey: .type)
			switch type {
			case "adguard":
				let value = try AdGuard(from: decoder)
				self = .adGuard(value)
			default:
				var codingPath = decoder.codingPath
				codingPath.append(CodingKeys.type)
				throw DecodingError.dataCorrupted(
					DecodingError.Context(
						codingPath: codingPath,
						debugDescription: "Unsupported widget type '\(type)'"
					)
				)
			}
		}
	}
}
