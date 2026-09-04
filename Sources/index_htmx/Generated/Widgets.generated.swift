// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Elementary

extension Config {
	enum Widget: Decodable {
		case adGuard(AdGuard)
		case homeAssistant(HomeAssistant)
		case radarr(Radarr)
		case sonarr(Sonarr)
		case tdarr(Tdarr)
		case technitium(Technitium)
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
				case "tdarr":
					let value = try Tdarr(from: decoder)
					self = .tdarr(value)
				case "technitium":
					let value = try Technitium(from: decoder)
					self = .technitium(value)
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

		func createService(id: String, publisher: Publisher, titleBadgeService: TitleBadgeService) -> (any WidgetService)? {
			switch self {
			case let .adGuard(config):
				AdGuard.Service(id: id, config: config, publisher: publisher, titleBadgeService: titleBadgeService)
			case let .homeAssistant(config):
				HomeAssistant.Service(id: id, config: config, publisher: publisher, titleBadgeService: titleBadgeService)
			case let .radarr(config):
				Radarr.Service(id: id, config: config, publisher: publisher, titleBadgeService: titleBadgeService)
			case let .sonarr(config):
				Sonarr.Service(id: id, config: config, publisher: publisher, titleBadgeService: titleBadgeService)
			case let .tdarr(config):
				Tdarr.Service(id: id, config: config, publisher: publisher, titleBadgeService: titleBadgeService)
			case let .technitium(config):
				Technitium.Service(id: id, config: config, publisher: publisher, titleBadgeService: titleBadgeService)
			case let .transmission(config):
				Transmission.Service(id: id, config: config, publisher: publisher, titleBadgeService: titleBadgeService)
			case .error:
				nil
			}
		}

		@HTMLBuilder
		func placeholder() -> some HTML & Sendable {
			switch self {
			case let .adGuard(config):
				config.render(response: nil)
			case let .homeAssistant(config):
				config.render(response: nil)
			case let .radarr(config):
				config.render(response: nil)
			case let .sonarr(config):
				config.render(response: nil)
			case let .tdarr(config):
				config.render(response: nil)
			case let .technitium(config):
				config.render(response: nil)
			case let .transmission(config):
				config.render(response: nil)
			case let .error(error):
				ErrorView(title: error)
			}
		}

		var hasBadge: Bool {
			switch self {
			case let .adGuard(config):
				config.hasBadge
			case let .homeAssistant(config):
				config.hasBadge
			case let .radarr(config):
				config.hasBadge
			case let .sonarr(config):
				config.hasBadge
			case let .tdarr(config):
				config.hasBadge
			case let .technitium(config):
				config.hasBadge
			case let .transmission(config):
				config.hasBadge
			case .error:
				false
			}
		}

		var hasDetails: Bool {
			switch self {
			case let .adGuard(config):
				!config.fieldConfig.isEmpty
			case let .homeAssistant(config):
				!config.fieldConfig.isEmpty
			case let .radarr(config):
				!config.fieldConfig.isEmpty
			case let .sonarr(config):
				!config.fieldConfig.isEmpty
			case let .tdarr(config):
				!config.fieldConfig.isEmpty
			case let .technitium(config):
				!config.fieldConfig.isEmpty
			case let .transmission(config):
				!config.fieldConfig.isEmpty
			case .error:
				true
			}
		}
	}
}
