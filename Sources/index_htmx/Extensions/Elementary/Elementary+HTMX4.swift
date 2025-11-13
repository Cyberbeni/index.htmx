import Elementary
import ElementaryHTMX

public extension HTMLAttribute.hx {
	static func stream(_ streamMode: HTMLAttributeValue.HTMX.StreamMode) -> HTMLAttribute {
		.init(name: "hx-stream", value: streamMode.rawValue)
	}
}

public extension HTMLAttributeValue.HTMX {
	enum StreamMode: String {
		case once
		case continuous
	}
}
