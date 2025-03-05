import Hummingbird

public extension Router {
	@discardableResult func add(if condition: Bool, middleware: any MiddlewareProtocol<Request, Response, Context>) -> Self {
		if condition {
			middlewares.add(middleware)
		}
		return self
	}
}
