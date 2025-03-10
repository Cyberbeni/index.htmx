struct WebManifest: Codable {
	let name: String
	let display: String
	let startUrl: String
	let icons: [AppIcon]
}
