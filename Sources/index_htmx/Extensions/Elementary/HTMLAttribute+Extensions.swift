import Elementary

// dimensions
extension HTMLTag.svg: @retroactive HTMLTrait.Attributes.dimensions {}

extension HTMLAttribute where Tag: HTMLTrait.Attributes.dimensions {
	static func width(_ value: String) -> Self {
		HTMLAttribute(name: "width", value: value)
	}

	static func height(_ value: String) -> Self {
		HTMLAttribute(name: "height", value: value)
	}
}

// position
extension HTMLTrait.Attributes {
	protocol position {}
}

extension HTMLAttribute where Tag: HTMLTrait.Attributes.position {
	static func x(_ value: String) -> Self {
		HTMLAttribute(name: "x", value: value)
	}

	static func y(_ value: String) -> Self {
		HTMLAttribute(name: "y", value: value)
	}
}

// role
public extension HTMLTrait.Attributes {
	protocol role {}
	enum Role: String {
		case button
	}
}

extension HTMLTag.a: HTMLTrait.Attributes.role {}

extension HTMLAttribute where Tag: HTMLTrait.Attributes.role {
	static func role(_ value: HTMLTrait.Attributes.Role) -> Self {
		HTMLAttribute(name: "role", value: value.rawValue)
	}

	static func role(_ value: String) -> Self {
		HTMLAttribute(name: "role", value: value)
	}
}

// alt
extension HTMLTrait.Attributes {
	protocol alt {}
}

extension HTMLTag.img: HTMLTrait.Attributes.alt {}

extension HTMLAttribute where Tag: HTMLTrait.Attributes.alt {
	static func alt(_ value: String) -> Self {
		HTMLAttribute(name: "alt", value: value)
	}
}

// sizes
extension HTMLTrait.Attributes {
	protocol sizes {}
}

extension HTMLTag.link: HTMLTrait.Attributes.sizes {}

extension HTMLAttribute where Tag: HTMLTrait.Attributes.sizes {
	static func sizes(_ value: String) -> Self {
		HTMLAttribute(name: "sizes", value: value)
	}
}

// media
extension HTMLTrait.Attributes {
	protocol media {}
}

extension HTMLTag.meta: HTMLTrait.Attributes.media {}

extension HTMLAttribute where Tag: HTMLTrait.Attributes.media {
	static func media(_ value: String) -> Self {
		HTMLAttribute(name: "media", value: value)
	}
}
