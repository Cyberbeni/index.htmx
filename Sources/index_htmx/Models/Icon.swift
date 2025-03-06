import Hummingbird

struct Icon: Codable {
	let src: String
	let type: String
	let sizes: String

	init?(runTimestamp: String, path: String, sizes: String) {
		if let fileExtension = path.fileExtension(),
		   let mediaType = MediaType.getMediaType(forExtension: fileExtension)
		{
			src = "/\(runTimestamp)/\(path)"
			type = mediaType.description
			self.sizes = sizes
		} else {
			return nil
		}
	}
}
