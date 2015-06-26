//
//  SignalMonitor.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	An observer that has explicitly referenceable identity.
public class SignalMonitor<T> {
	public var handler: (T->())?
	
	///
	
	private func handle(signal: T) {
		handler?(signal)
	}
}
extension SignalChannel {
	///	Please note that channel does not keep a strong reference
	///	to monitors. You're responsible to keep them alive while 
	///	they're attached to a channel.
	public func register(monitor: SignalMonitor<T>) {
		register(ObjectIdentifier(monitor)) { [weak monitor] in monitor!.handle($0) }
	}
	public func deregister(monitor: SignalMonitor<T>) {
		deregister(ObjectIdentifier(monitor))
	}
}


