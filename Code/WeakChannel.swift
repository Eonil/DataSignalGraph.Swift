//
//  WeakChannel.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public struct WeakChannel<Channel: StateChannelType>: Viewable, Emittable {
	public init(_ channel: Channel) {
		_channel    =	channel
	}
	public var snapshot: Channel.Snapshot {
		get {
			return	_channel.snapshot
		}
	}
	public func register(identifier: ObjectIdentifier, handler: Channel.OutgoingSignal -> ()) {
		_channel.register(identifier, handler: handler)
	}
	public func deregister(identifier: ObjectIdentifier) {
		_channel.deregister(identifier)
	}
	public func register<S : SensitiveStationType where S.IncomingSignal == Channel.OutgoingSignal>(s: S) {
		_channel.register(s)
	}
	public func deregister<S : SensitiveStationType where S.IncomingSignal == Channel.OutgoingSignal>(s: S) {
		_channel.deregister(s)
	}

	///

	private unowned let	_channel	:	Channel
}
















