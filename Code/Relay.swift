//
//  Caster.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

//public class Emitter<T>: EmissiveStationType {
//	public typealias	OutgoingSignal		=	T
//
//	public func register(identifier: ObjectIdentifier, handler: OutgoingSignal -> ()) {
//	}
//	public func deregister(identifier: ObjectIdentifier) {
//	}
//	public func deregister<S : SensitiveStationType>(_: S) {
//	}
//	public func register<S : SensitiveStationType>(_: S) {
//	}
//}
//public class Sensor<T>: SensitiveStationType {
//	public func cast(signal: T) {
//	}
//}
public class Relay<T>: SensitiveStationType, EmissiveStationType {
	public typealias	IncomingSignal		=	T
	public typealias	OutgoingSignal		=	T

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

	private var	_handlers	=	Dictionary<ObjectIdentifier, OutgoingSignal->()>()
}
public class Monitor<T>: SensitiveStationType {
	public var handler: (T->())?

	public func cast(signal: T) {
		handler?(signal)
	}
}















