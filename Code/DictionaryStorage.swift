//
//  DictionaryStorage.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class DictionaryStorage<K: Hashable, V>: DictionaryStorageType {
	typealias	Snapshot		=	[K:V]
	typealias	Transaction		=	CollectionTransaction<K,V>
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
	
	private var	_snapshot	=	Snapshot()
	private let	_relay		=	Relay<OutgoingSignal>()
}
extension DictionaryStorage: EditableDictionary, SequenceType {
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
	var endIndex: Snapshot.Index {
		get {
			return	_snapshot.endIndex
		}
	}
	public func generate() -> Snapshot.Generator {
		return	_snapshot.generate()
	}

	///

	public subscript(key: K) -> V? {
		get {
			return	_snapshot[key]
		}
		set(v) {
			let	maybeOld	=	_snapshot[key]
			let	maybeNew	=	v

			switch (maybeOld, maybeNew) {
			case (nil, nil):
				break

			case (nil, _):
				apply(CollectionTransaction([(key, nil, maybeNew)]))

			case (_, nil):
				apply(CollectionTransaction([(key, maybeOld, nil)]))

			case (_, _):
				apply(CollectionTransaction([(key, maybeOld, maybeNew)]))
			}
		}
	}

	///

	public func updateValue(value: V, forKey key: K) -> V? {
		let	maybeOld	=	_snapshot[key]
		let	new		=	value
		switch (maybeOld, new) {
		case (nil,_):		apply(CollectionTransaction([(key, nil, new)]))
		case (_,_):		apply(CollectionTransaction([(key, maybeOld!, new)]))
		}
		return	maybeOld
	}

	public func removeAtIndex(index: DictionaryIndex<K, V>) {
		let	pair	=	_snapshot[index]
		let	key	=	pair.0
		let	old	=	pair.1
		apply(CollectionTransaction([(key, old, nil)]))
	}

	public func removeValueForKey(key: K) -> V? {
		let	maybeOld	=	_snapshot[key]
		if let old = maybeOld {
			apply(CollectionTransaction([(key, old, nil)]))
		}
		return	maybeOld
	}

	public func removeAll() {
		var	muts		=	Array<Transaction.Mutation>()
		for (k,v) in _snapshot {
			muts.append((k, v, nil))
		}
		apply(CollectionTransaction(muts))
	}

	public var keys: LazyForwardCollection<MapCollectionView<[K:V],K>> {
		get {
			return	_snapshot.keys
		}
	}
	public var values: LazyForwardCollection<MapCollectionView<[K:V],V>> {
		get {
			return	_snapshot.values
		}
	}

}











public extension DictionaryStorage {
	public typealias	Channel	=	WeakChannel<DictionaryStorage<K,V>>

	public func channelize() -> Channel {
		return	Channel(self)
	}
}










