import Elementary
import ElementaryHTMX

public extension HTMLTag {
	enum hxPartial: HTMLTrait.Paired { public static let name = "hx-partial" }
}

public typealias hxPartial<Content: HTML> = HTMLElement<HTMLTag.hxPartial, Content>

public extension HTMLAttribute.hx {
	static func config(_ value: String) -> HTMLAttribute {
		.init(name: "hx-config", value: value)
	}
}

public extension HTMLAttributeValue.HTMX {
	enum StreamMode: String {
		case once
		case continuous
	}
}
