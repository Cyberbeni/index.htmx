import Elementary

struct HomeAssistant: WidgetConfig, AccessTokenAuth {
	// TODO: use WebSocket API instead of polling
	// https://developers.home-assistant.io/docs/api/websocket/
	// PoC code: https://github.com/Cyberbeni/Wiring/blob/9f6bb95aa23a600e6826bd7e7f9aa146129694f9/Sources/Wiring/HomeAssistantWebSocket/HomeAssistantWebSocket.swift
	typealias Service = DefaultWidgetService<Self>

	let url: String
	let accessToken: String
	let fields: [Field]?

	var path: String { "/api/template" }
	static var defaultFields: [Field] { [] }
	var pollingInterval: Int { fieldConfig.contains(where: \.isPerson) ? 5 : 30 }

	enum Field: RawRepresentable, Decodable {
		case person(entityId: String, name: String)
		case battery(entityId: String)

		var rawValue: String {
			switch self {
			case let .person(entityId, name):
				"person/\(entityId)/\(name)"
			case let .battery(entityId):
				"battery/\(entityId)"
			}
		}

		init?(rawValue: String) {
			var parts = rawValue.split(separator: "/")
			switch parts.first {
			case "person":
				if let name = parts.popLast(),
				   let entityId = parts.popLast()
				{
					self = .person(entityId: String(entityId), name: String(name))
				} else {
					return nil
				}
			case "battery":
				if let entityId = parts.popLast() {
					self = .battery(entityId: String(entityId))
				} else {
					return nil
				}
			default:
				return nil
			}
		}

		var isPerson: Bool {
			switch self {
			case .person: true
			default: false
			}
		}

		var template: String {
			switch self {
			case let .person(entityId, _):
				"{{states('person.\(entityId)')}}"
			case let .battery(entityId):
				"{{states('sensor.\(entityId)')}}"
			}
		}

		var title: String {
			switch self {
			case let .person(_, name): name
			case .battery: "Battery"
			}
		}

		func value(for response: String?) -> String {
			guard let response else { return "-" }
			switch self {
			case .person:
				return response
			case .battery:
				if let value = Double(response) {
					return Formatter.percentage(value, base: 100)
				} else {
					return response
				}
			}
		}
	}

	typealias Response = String

	@HTMLBuilder
	func render(response: Response?) -> some HTML {
		if let response {
			for (field, response) in zip(fieldConfig, response.split(separator: "\n", omittingEmptySubsequences: false)) {
				DetailItem(title: field.title, value: field.value(for: String(response)))
			}
		} else {
			for field in fieldConfig {
				DetailItem(title: field.title, value: field.value(for: nil))
			}
		}
	}

	struct Request: Encodable {
		let template: String
	}

	func requestData() throws -> Data? {
		let request = Request(template: fieldConfig.map(\.template).joined(separator: "\n"))
		return try Service.jsonEncoder().encode(request)
	}
}
