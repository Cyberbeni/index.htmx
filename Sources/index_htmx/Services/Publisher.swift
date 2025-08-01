import NIO
import ServiceLifecycle

/// Modified version of Publisher from this example
/// https://github.com/hummingbird-project/hummingbird-examples/blob/60042c53f940820e664d8556042f7c241bd48755/server-sent-events/Sources/App/Publisher.swift
actor Publisher: Service {
	typealias SubscriptionID = UUID
	typealias Value = ByteBuffer
	enum SubscriptionCommand {
		case add(SubscriptionID, AsyncStream<Value>.Continuation)
		case remove(SubscriptionID)
	}

	private nonisolated let (subStream, subSource) = AsyncStream<SubscriptionCommand>.makeStream()
	private var subscriptions = [SubscriptionID: AsyncStream<Value>.Continuation]()
	private var cachedValues = [String: Value]()

	/// Publish to service
	/// - Parameter value: Value being published
	func publish(_ value: Value, id: String) {
		guard cachedValues[id] != value else { return }
		cachedValues[id] = value
		for subscription in subscriptions.values {
			subscription.yield(value)
		}
	}

	///  Subscribe to service
	/// - Returns: AsyncStream of values, and subscription identifier
	nonisolated func subscribe() -> (AsyncStream<Value>, SubscriptionID) {
		let id = SubscriptionID()
		let (stream, source) = AsyncStream<Value>.makeStream()
		subSource.yield(.add(id, source))
		Task {
			let values = await cachedValues.values
			for value in values {
				source.yield(value)
			}
		}
		return (stream, id)
	}

	///  Unsubscribe from service
	/// - Parameter id: Subscription identifier
	nonisolated func unsubscribe(_ id: SubscriptionID) {
		subSource.yield(.remove(id))
	}

	/// Service run function
	func run() async throws {
		try await withGracefulShutdownHandler {
			for try await command in self.subStream {
				switch command {
				case let .add(id, source):
					self._addSubsciber(id, source: source)
				case let .remove(id):
					self._removeSubsciber(id)
				}
			}
		} onGracefulShutdown: {
			self.subSource.finish()
		}
	}

	private func _addSubsciber(_ id: SubscriptionID, source: AsyncStream<Value>.Continuation) {
		subscriptions[id] = source
	}

	private func _removeSubsciber(_ id: SubscriptionID) {
		subscriptions[id]?.finish()
		subscriptions[id] = nil
	}
}
