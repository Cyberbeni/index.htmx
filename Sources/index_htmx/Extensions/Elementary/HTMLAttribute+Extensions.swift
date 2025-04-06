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
public extension HTMLAttributeValue.Role {
	static var button: Self { "button" }
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

// aria-hidden
extension HTMLTrait.Attributes {
	protocol ariaHidden {}
}

extension HTMLTag.div: HTMLTrait.Attributes.ariaHidden {}
extension HTMLTag.img: HTMLTrait.Attributes.ariaHidden {}
extension HTMLTag.svg: HTMLTrait.Attributes.ariaHidden {}

extension HTMLAttribute where Tag: HTMLTrait.Attributes.ariaHidden {
	static func ariaHidden(_ value: Bool) -> Self {
		HTMLAttribute(name: "aria-hidden", value: "\(value)")
	}
}
