//
//  SetStorage.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright © 2015 Eonil. All rights reserved.
//

public class SetStorage<T: Hashable>: SetStorageType {
	typealias	Element			=	T
	typealias	Snapshot		=	Set<T>
	typealias	Transaction		=	CollectionTransaction<T,()>
	typealias	OutgoingSignal		=	StateSignal<Snapshot,Transaction>

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
			_snapshot	=	v
		}
	}
	public func apply(transaction: Transaction) {
		_relay.cast(StateSignal.willEnd(_snapshot, by: transaction))
		Algorithms.apply(transaction, to: &_snapshot)
		_relay.cast(StateSignal.didBegin(_snapshot, by: transaction))
	}
	public func register(identifier: ObjectIdentifier, handler: OutgoingSignal->()) {
		_relay.register(identifier, handler: handler)
		_relay.cast(StateSignal.didBegin(_snapshot, by: nil))
	}
	public func deregister(identifier: ObjectIdentifier) {
		_relay.cast(StateSignal.willEnd(_snapshot, by: nil))
		_relay.deregister(identifier)
	}
	public func register<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.register(s)
		_relay.cast(StateSignal.didBegin(_snapshot, by: nil))
	}
	public func deregister<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.cast(StateSignal.willEnd(_snapshot, by: nil))
		_relay.deregister(s)
	}

	///

	private var	_snapshot	=	Set<T>()
	private let	_relay		=	Relay<OutgoingSignal>()
}
extension SetStorage: EditableSet {
	public var count: Int {
		get {
			return	_snapshot.count
		}
	}
	public func generate() -> Snapshot.Generator {
		return	_snapshot.generate()
	}

	///


	public func insert(member: T) {
		let	tran	=	CollectionTransaction([(member, nil, ())])
		apply(tran)
	}
	public func remove(member: T) -> T? {
		let	ele	=	_snapshot.contains(member) ? member : nil as T?
		let	tran	=	CollectionTransaction([(member, (), nil)])
		apply(tran)
		return	ele
	}
}
















public extension SetStorage {
	public typealias	Channel	=	WeakChannel<SetStorage<T>>

	public func channelize() -> Channel {
		return	Channel(self)
	}
}



