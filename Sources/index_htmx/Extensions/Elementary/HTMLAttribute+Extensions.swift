import Elementary

extension HTMLTag.svg: @retroactive HTMLTrait.Attributes.dimensions {}

extension HTMLAttribute where Tag: HTMLTrait.Attributes.dimensions {
    static func width(_ value: String) -> Self {
        HTMLAttribute(name: "width", value: value)
    }

    static func height(_ value: String) -> Self {
        HTMLAttribute(name: "height", value: value)
    }
}

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
