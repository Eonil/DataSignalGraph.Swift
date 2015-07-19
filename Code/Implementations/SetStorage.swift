//
//  SetStorage.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/03.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class SetStorage<T: Hashable>: SetStorageType {
	public typealias	Element		=	T
	public typealias	Snapshot	=	Set<T>
	public typealias	Transaction	=	CollectionTransaction<Set<T>,()>
	public typealias	OutgoingSignal	=	TimingSignal<Snapshot, Transaction>

	public typealias	Signal		=	OutgoingSignal

	///

	public init(_ snapshot: Set<T>) {
		_snapshot	=	snapshot
	}
	deinit {
	}

	///

	public var snapshot: Set<T> {
		get {
			return	_snapshot
		}
		set(v) {
			apply(Transaction([
				(_snapshot, (), nil),
				(v, nil, ()),
				]))
		}
	}
	public func apply(transaction: Transaction) {
		_executeWithCastFlagging() {
			StateStorageUtility.apply(transaction, to: &_snapshot, relay: _relay)
		}
	}
	public func register(identifier: ObjectIdentifier, handler: Signal->()) {
		_executeWithCastFlagging() {
			_relay.register(identifier, handler: handler)
			handler(HOTFIX_TimingSignalUtility.didBeginStateBySession(_snapshot))
		}
	}
	public func deregister(identifier: ObjectIdentifier) {
		_executeWithCastFlagging() {
			_relay.handlerForIdentifier(identifier)(HOTFIX_TimingSignalUtility.willEndStateBySession(_snapshot))
			_relay.deregister(identifier)
		}
	}
	public func register<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_executeWithCastFlagging() {
			register(ObjectIdentifier(s))	{ [weak s] in s!.cast($0) }
		}
	}
	public func deregister<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_executeWithCastFlagging() {
			deregister(ObjectIdentifier(s))
		}
	}
//	public func register<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal, S: StateSegmentMonitor>(s: S) {
//		_frequentRelay.register(ObjectIdentifier(s))	{ [weak s] in s!.cast($0) }
//		s.cast(HOTFIX_TimingSignalUtility.didBeginStateBySession(_snapshot))
//	}
//	public func deregister<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal, S: StateSegmentMonitor>(s: S) {
//		s.cast(HOTFIX_TimingSignalUtility.willEndStateBySession(_snapshot))
//		_frequentRelay.deregister(ObjectIdentifier(s))
//	}

	///

	private typealias	_Signal		=	Signal

	private let		_relay		=	Relay<Signal>()
	private var		_snapshot	:	Set<T>

	private var		_isCasting	=	false

	private func _cast(signal: Signal) {
		_relay.cast(signal)
	}

	private func _executeWithCastFlagging(@noescape code: ()->()) {
		assert(_isCasting == false, "You cannot call `apply` while some signaling is under casting.")
		_isCasting	=	true
		code()
		_isCasting	=	false
	}
}

extension SetStorage: EditableSet, CollectionType, SequenceType {
	public var count: Int {
		get {
			return	_snapshot.count
		}
	}
	public var startIndex: Snapshot.Index {
		get {
			return	_snapshot.startIndex
		}
	}
	public var endIndex: Snapshot.Index {
		get {
			return	_snapshot.endIndex
		}
	}
	public func generate() -> Snapshot.Generator {
		return	_snapshot.generate()
	}

	///

	public subscript(index: Snapshot.Index) -> Snapshot.Element {
		get {
			return	_snapshot[index]
		}
	}

	///

	public func insert(member: T) {
		let	tran	=	CollectionTransaction([([member] as Set<T>, nil, ())])
		apply(tran)
	}
	public func remove(member: T) -> T? {
		let	ele	=	_snapshot.contains(member) ? member : nil as T?
		let	tran	=	CollectionTransaction([([member] as Set<T>, (), nil)])
		apply(tran)
		return	ele
	}
	public func removeAll() {
		let	tran	=	CollectionTransaction([(_snapshot, (), nil)])
		apply(tran)
	}
}






private func _singleElementCollectionTransaction<T>(identity: Int, past: T?, future: T?) -> CollectionTransaction<Int,T> {
	return	CollectionTransaction([])
}
