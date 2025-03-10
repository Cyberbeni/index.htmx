// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Elementary

extension Config {
	enum Widget: Decodable {
		case adGuard(AdGuard)
		case sonarr(Sonarr)
		case transmission(Transmission)
		case error(String)

		enum CodingKeys: String, CodingKey {
			case type
		}

		init(from decoder: Decoder) {
			do {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				let type = try container.decode(String.self, forKey: .type)
				switch type {
				case "adguard":
					let value = try AdGuard(from: decoder)
					self = .adGuard(value)
				case "sonarr":
					let value = try Sonarr(from: decoder)
					self = .sonarr(value)
				case "transmission":
					let value = try Transmission(from: decoder)
					self = .transmission(value)
				default:
					self = .error("Unsupported type: \(type)")
				}
			} catch {
				self = .error("Failed to parse widget config")
			}
		}

		func createService(id: String, publisher: Publisher) -> (any WidgetService)? {
			switch self {
			case let .adGuard(config):
				AdGuardService(id: id, config: config, publisher: publisher)
			case let .sonarr(config):
				SonarrService(id: id, config: config, publisher: publisher)
			case let .transmission(config):
				TransmissionService(id: id, config: config, publisher: publisher)
			case .error:
				nil
			}
		}

		@HTMLBuilder
		func placeholder() -> some HTML {
			switch self {
			case let .adGuard(config):
				config.render(response: nil)
			case let .sonarr(config):
				config.render(response: nil)
			case let .transmission(config):
				config.render(response: nil)
			case let .error(error):
				ErrorView(title: error)
			}
		}
	}
}
