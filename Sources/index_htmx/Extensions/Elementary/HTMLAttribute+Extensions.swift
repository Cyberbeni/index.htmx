import Elementary

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

extension HTMLAttribute where Tag: HTMLTrait.Attributes.ariaHidden {
	static func ariaHidden(_ value: Bool) -> Self {
		HTMLAttribute(name: "aria-hidden", value: "\(value)")
	}
}

extension SVGTrait.Attributes {
	protocol ariaHidden {}
}

extension SVGTag.svg: SVGTrait.Attributes.ariaHidden {}

extension SVGAttribute where Tag: SVGTrait.Attributes.ariaHidden {
	static func ariaHidden(_ value: Bool) -> Self {
		SVGAttribute(name: "aria-hidden", value: "\(value)")
	}
}
