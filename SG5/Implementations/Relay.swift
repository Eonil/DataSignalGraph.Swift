//
//  Relay.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//

///	Routes signals to multiple handlers.
///
public class Relay<T>: SensitiveStationType, EmissiveStationType {
	public typealias	IncomingSignal		=	T
	public typealias	OutgoingSignal		=	T

	public init() {
	}
	deinit {
		assert(_handlers.count == 0, "You must deregister all handlers/sensors before this object dies.")
	}

	///

	public func cast(signal: T) {
		for h in _handlers.values {
			h(signal)
		}
	}

	public func register(identifier: ObjectIdentifier, handler: OutgoingSignal -> ()) {
		assert(_handlers[identifier] == nil)
		_handlers[identifier]	=	handler
	}
	public func deregister(identifier: ObjectIdentifier) {
		assert(_handlers[identifier] != nil)
		_handlers[identifier]	=	nil
	}
	public func register<S : SensitiveStationType where S.IncomingSignal == T>(s: S) {

		register(ObjectIdentifier(s), handler: { [weak s] in s!.cast($0) })
	}
	public func deregister<S : SensitiveStationType where S.IncomingSignal == T>(s: S) {
		deregister(ObjectIdentifier(s))
	}

	///

	internal func handlerForIdentifier(identifier: ObjectIdentifier) -> OutgoingSignal->() {
		return	_handlers[identifier]!
	}

	///

	private var	_handlers	=	Dictionary<ObjectIdentifier, OutgoingSignal->()>()
}
public class Monitor<T>: SensitiveStationType {

	public init() {
	}
	
	public var handler: (T->())?

	public func cast(signal: T) {
		handler?(signal)
	}
}















