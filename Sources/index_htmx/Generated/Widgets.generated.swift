// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Elementary

extension Config {
	enum Widget: Decodable {
		case adGuard(AdGuard)
		case homeAssistant(HomeAssistant)
		case radarr(Radarr)
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
				case "homeassistant":
					let value = try HomeAssistant(from: decoder)
					self = .homeAssistant(value)
				case "radarr":
					let value = try Radarr(from: decoder)
					self = .radarr(value)
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
				AdGuard.Service(id: id, config: config, publisher: publisher)
			case let .homeAssistant(config):
				HomeAssistant.Service(id: id, config: config, publisher: publisher)
			case let .radarr(config):
				Radarr.Service(id: id, config: config, publisher: publisher)
			case let .sonarr(config):
				Sonarr.Service(id: id, config: config, publisher: publisher)
			case let .transmission(config):
				Transmission.Service(id: id, config: config, publisher: publisher)
			case .error:
				nil
			}
		}

		// FIXME: make the return type `sending some HTML` after this is fixed: https://github.com/swiftlang/swift/issues/84318
		@HTMLBuilder
		func placeholder() -> some HTML {
			switch self {
			case let .adGuard(config):
				config.render(response: nil)
			case let .homeAssistant(config):
				config.render(response: nil)
			case let .radarr(config):
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
