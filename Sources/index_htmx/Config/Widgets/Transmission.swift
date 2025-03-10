import Elementary

struct Transmission: WidgetConfig, PasswordAuth {
	let url: String
	let user: String
	let password: String
	let rpcUrl: String?
	let fields: [Field]?

	var path: String { (rpcUrl ?? "/transmission/") + "rpc" }
	static var defaultFields: [Field] { [.leech, .download, .seed, .upload] }

	enum Field: String, Decodable {
		case leech
		case download
		case seed
		case upload

		var title: String {
			switch self {
			case .leech: "Leech"
			case .download: "Download"
			case .seed: "Seed"
			case .upload: "Upload"
			}
		}

		func value(for response: Response?) -> String {
			guard let response else { return "-" }
			// TODO: better formatting
			// TODO: leech/seed stopped count
			switch self {
			case .leech:
				let count = response.arguments.torrents.count(where: { $0.status == .downloading })
				return Formatter.string(from: count)
			case .seed:
				let count = response.arguments.torrents.count(where: { $0.status == .seeding })
				return Formatter.string(from: count)
			case .download:
				let speed = response.arguments.torrents.reduce(0) { $0 + $1.rateDownload }
				return Formatter.string(from: speed)
			case .upload:
				let speed = response.arguments.torrents.reduce(0) { $0 + $1.rateUpload }
				return Formatter.string(from: speed)
			}
		}
	}

	/// https://github.com/transmission/transmission/blob/main/docs/rpc-spec.md
	struct Response: Decodable {
		let arguments: Arguments
		let result: Result

		struct Arguments: Decodable {
			let torrents: [Torrent]

			struct Torrent: Decodable {
				let percentDone: Double
				let rateDownload: Int // B/s
				let rateUpload: Int // B/s
				let status: Status

				enum Status: Int, Decodable {
					case stopped
					case queuedToVerifyLocalData
					case verifyingLocalData
					case queuedToDownload
					case downloading
					case queuedToSeed
					case seeding
				}
			}
		}

		enum Result: RawRepresentable, Decodable {
			case success
			case error(String)

			var rawValue: String {
				switch self {
				case .success:
					"success"
				case let .error(error):
					error
				}
			}

			init(rawValue: String) {
				if rawValue == "success" {
					self = .success
				} else {
					self = .error(rawValue)
				}
			}
		}
	}

	@HTMLBuilder
	func render(response: Response?) -> some HTML {
		// TODO: error
		for field in fieldConfig {
			DetailItem(title: field.title, value: field.value(for: response))
		}
	}
}
