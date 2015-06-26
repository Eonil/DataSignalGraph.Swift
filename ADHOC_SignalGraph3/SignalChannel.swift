//
//  SignalChannel.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/25.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



///	Signal casting order is undefined.
///	You cannot assume any order between handlers.
///	Anyway, you can make signaling order if it is truly required.
///
///	1.	Chain channel to a `SignalCaster`.
///	2.	Override `cast` method.
///	3.	Rout signal to desired channel at there.
///
///	Signal casting is done in caller thread.
///
public class SignalChannel<T>: ChannelType {
	public typealias	Signal	=	T
	
	deinit {
		assert(_map.count == 0, "You must deregister all handlers BEFORE this channel dies.")
	}
	
	public func register(identifier: ObjectIdentifier, handler: T->()) {
		assert(_map[identifier] == nil)
		_map[identifier]	=	handler
	}
	public func deregister(identifier: ObjectIdentifier) {
		assert(_map[identifier] != nil)
		_map[identifier]	=	nil
	}

	///
	
	internal func cast(signal: T) {
		for handler in _map.values {
			handler(signal)
		}
	}
	
	///
	
	private typealias	_Handler	=	T->()
	
	private var		_map		=	[ObjectIdentifier: _Handler]()
}
extension SignalChannel {
	public func register(channel: SignalChannel<T>) {
		register(ObjectIdentifier(channel)) { [weak channel] in channel!.cast($0) }
	}
	public func deregister(channel: SignalChannel<T>) {
		deregister(ObjectIdentifier(channel))
	}
}










public class SignalCaster<T>: SignalChannel<T> {
	public override func cast(signal: T) {
		super.cast(signal)
	}
}














