//
//  ValueStorage.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

//public class ValueStorage<T>: ValueStorageType {
public class ValueStorage<T> {
	typealias	Element			=	T
	typealias	Snapshot		=	T
//	typealias	Transaction		=	ValueTransaction<T>
	typealias	OutgoingSignal		=	StateSignal<T,ValueTransaction<T>>

	public typealias	Signal			=	OutgoingSignal
	
	///

	public init(_ snapshot: Snapshot) {
		_snapshot	=	snapshot
	}

	public var snapshot: Snapshot {
		get {
			return	_snapshot
		}
		set(v) {
//			let	tran	=	Transaction([(snapshot,v)])
//			apply(tran)
		}
	}
	public var state: Snapshot {
		get {
			return	_snapshot
		}
		set(v) {
//			let	tran	=	Transaction([(state,v)])
//			apply(tran)
		}
	}
//	public func apply(transaction: ValueTransaction<T>) {
//		_relay.cast(StateSignal.willEnd(_snapshot, by: transaction))
//		for m in transaction.mutations {
//			_snapshot	=	m.future
//		}
//		_relay.cast(StateSignal.didBegin(_snapshot, by: transaction))
//	}
//	public func register(identifier: ObjectIdentifier, handler: OutgoingSignal->()) {
//		_relay.register(identifier, handler: handler)
//		_relay.cast(StateSignal.didBegin(_snapshot, by: _snapshot))
//	}
//	public func deregister(identifier: ObjectIdentifier) {
//		_relay.cast(StateSignal.willEnd(_snapshot, by: _snapshot))
//		_relay.deregister(identifier)
//	}
//	public func register<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
//		_relay.register(s)
//		_relay.cast(StateSignal.didBegin(_snapshot, by: _snapshot))
//	}
//	public func deregister<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
//		_relay.cast(StateSignal.willEnd(_snapshot, by: _snapshot))
//		_relay.deregister(s)
//	}

	///

	private var	_snapshot	:	Snapshot
	private let	_relay		=	Relay<OutgoingSignal>()
}
//extension ValueStorage: Editable, SequenceType {
//	public func generate() -> GeneratorOfOne<Snapshot> {
//		return	GeneratorOfOne(_snapshot)
//	}
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//public extension ValueStorage {
//	public typealias	Channel	=	WeakChannel<ValueStorage<T>>
//
//	public func channelize() -> Channel {
//		return	Channel(self)
//	}
//}










