//
//  DictionaryStorage.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/04.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class DictionaryStorage<K: Hashable, V>: DictionaryStorageType {
	public typealias	Key		=	K
	public typealias	Value		=	V
	public typealias	Snapshot	=	[K:V]
	public typealias	Transaction	=	CollectionTransaction<K,V>
	public typealias	OutgoingSignal	=	StateSignal<Snapshot, Transaction>

	public typealias	Signal		=	OutgoingSignal

	///

	public init(_ snapshot: [K:V]) {
		_snapshot	=	snapshot
	}
	deinit {
	}

	///

	public var snapshot: [K:V] {
		get {
			return	_snapshot
		}
		set(v) {
			var	ms	=	Array<Transaction.Mutation>()
			for pair in _snapshot {
				ms.append((pair.0, pair.1, nil))
			}
			for pair in v {
				ms.append((pair.0, nil, pair.1))
			}
			let	t	=	Transaction(ms)
			apply(t)
		}
	}
	public func apply(transaction: Transaction) {
		StateStorageUtility.apply(transaction, to: &_snapshot, relay: _relay)
	}
	public func register(identifier: ObjectIdentifier, handler: Signal->()) {
		_relay.register(identifier, handler: handler)
		handler(HOTFIX_StateSignalUtility.didBeginStateBySession(_snapshot))
	}
	public func deregister(identifier: ObjectIdentifier) {
		_relay.handlerForIdentifier(identifier)(HOTFIX_StateSignalUtility.willEndStateBySession(_snapshot))
		_relay.deregister(identifier)
	}
	public func register<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		register(ObjectIdentifier(s))	{ [weak s] in s!.cast($0) }
	}
	public func deregister<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		deregister(ObjectIdentifier(s))
	}
//	public func register<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal, S: StateSegmentMonitor>(s: S) {
//		_frequentRelay.register(ObjectIdentifier(s))	{ [weak s] in s!.cast($0) }
//		s.cast(HOTFIX_StateSignalUtility.didBeginStateBySession(_snapshot))
//	}
//	public func deregister<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal, S: StateSegmentMonitor>(s: S) {
//		s.cast(HOTFIX_StateSignalUtility.willEndStateBySession(_snapshot))
//		_frequentRelay.deregister(ObjectIdentifier(s))
//	}

	///

	private typealias	_Signal		=	Signal

	private let		_relay		=	Relay<Signal>()
	private var		_snapshot	:	[K:V]

	private func _cast(signal: Signal) {
		_relay.cast(signal)
	}
}

extension DictionaryStorage: EditableDictionary, CollectionType, SequenceType {
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
	public subscript(key: Key) -> Value? {
		get {
			return	_snapshot[key]
		}
		set(v) {
			var	ms	=	Array<Transaction.Mutation>()
			if let old = _snapshot[key] {
				ms.append((key, old, nil))
			}
			if let new = v {
				ms.append((key, nil, new))
			}
			apply(Transaction(ms))
		}
	}

	///

	public func updateValue(value: Value, forKey key: Key) -> Value? {
		let	new	=	value
		if let old = _snapshot[key] {
			apply(Transaction([(key, old, new)]))
			return	old
		}
		return	nil
	}
	public func removeValueForKey(key: Key) -> Value? {
		if let old = _snapshot[key] {
			apply(Transaction([(key, old, nil)]))
			return	old
		}
		return	nil
	}
	public func removeAll() {
		var	ms	=	Array<Transaction.Mutation>()
		for pair in _snapshot {
			ms.append((pair.0, pair.1, nil))
		}
		let	t	=	Transaction(ms)
		apply(t)
	}
}





