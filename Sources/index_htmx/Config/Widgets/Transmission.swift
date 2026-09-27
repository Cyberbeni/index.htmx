import Elementary

struct Transmission: WidgetConfig, PasswordAuth {
	let url: String
	let user: String?
	let password: String?
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
			guard let result = response?.result else { return "-" }
			switch self {
			case .leech:
				let runningCount = result.torrents.count(where: { $0.status == .downloading })
				let totalCount = result.torrents.count(where: {
					[.queuedToVerifyLocalData, .verifyingLocalData, .queuedToDownload, .downloading].contains($0.status) ||
						($0.status == .stopped && $0.percentDone != 1)
				})
				if runningCount == totalCount {
					return Formatter.number(runningCount)
				} else {
					return "\(Formatter.number(runningCount)) (\(Formatter.number(totalCount)))"
				}
			case .seed:
				let runningCount = result.torrents.count(where: { $0.status == .seeding })
				let totalCount = result.torrents.count(where: {
					[.queuedToSeed, .seeding].contains($0.status) ||
						($0.status == .stopped && $0.percentDone == 1)
				})
				if runningCount == totalCount {
					return Formatter.number(runningCount)
				} else {
					return "\(Formatter.number(runningCount)) (\(Formatter.number(totalCount)))"
				}
			case .download:
				let speed = result.torrents.reduce(0) { $0 + $1.rateDownload }
				return Formatter.transferSpeed(speed)
			case .upload:
				let speed = result.torrents.reduce(0) { $0 + $1.rateUpload }
				return Formatter.transferSpeed(speed)
			}
		}
	}

	/// https://github.com/transmission/transmission/blob/main/docs/rpc-spec.md
	struct Response: Decodable {
		let result: Result?
		let error: Error?

		struct Result: Decodable {
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

		struct Error: Decodable {
			let code: Int
			let message: String
			let data: ErrorData?

			struct ErrorData: Decodable {
				let errorString: String?
			}
		}
	}

	@HTMLBuilder
	func render(response: Response?) -> some HTML & Sendable {
		if let error = response?.error {
			ErrorView(title: "Error code: \(error.code)")
		} else {
			for field in fieldConfig {
				DetailItem(title: field.title, value: field.value(for: response))
			}
		}
	}
}
