import Elementary

extension HTMLTag {
	enum use: HTMLTrait.Paired,
		HTMLTrait.Attributes.dimensions,
		HTMLTrait.Attributes.position,
		HTMLTrait.Attributes.href
	{
		static let name = "use"
	}
}

typealias use<Content: HTML> = HTMLElement<HTMLTag.use, Content>
