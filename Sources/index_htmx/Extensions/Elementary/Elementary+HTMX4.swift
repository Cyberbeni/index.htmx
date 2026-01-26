import Elementary
import ElementaryHTMX

public extension HTMLTag {
	enum hxPartial: HTMLTrait.Paired { public static let name = "hx-partial" }
}

public typealias hxPartial<Content: HTML> = HTMLElement<HTMLTag.hxPartial, Content>

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
