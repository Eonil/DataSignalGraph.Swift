//
//  WeakChannel.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public struct WeakChannel<Storage: WatchableStorageType>: Viewable, Emittable {
	public init(_ storage: Storage) {
		_storage	=	storage
	}
	public var snapshot: Storage.Snapshot {
		get {
			return	_storage.snapshot
		}
	}
	public func register(identifier: ObjectIdentifier, handler: Storage.OutgoingSignal -> ()) {
		_storage.register(identifier, handler: handler)
	}
	public func deregister(identifier: ObjectIdentifier) {
		_storage.deregister(identifier)
	}
	public func register<S : SensitiveStationType where S.IncomingSignal == Storage.OutgoingSignal>(s: S) {
		_storage.register(s)
	}
	public func deregister<S : SensitiveStationType where S.IncomingSignal == Storage.OutgoingSignal>(s: S) {
		_storage.deregister(s)
	}

	///

	private unowned let	_storage	:	Storage
}